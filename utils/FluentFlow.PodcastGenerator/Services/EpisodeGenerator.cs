using System.Text.Json;
using FluentFlow.PodcastGenerator.Models;

namespace FluentFlow.PodcastGenerator.Services;

/// <summary>Orquestra: JSON → TTS por fala → PCM com pausas → MP3 (+ versão lenta) → transcrição.</summary>
public sealed class EpisodeGenerator(PodcastSettings settings, AzureTtsService tts, FfmpegEncoder encoder, string outputDir)
{
    public static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
        WriteIndented = true,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
    };

    public static async Task<Episode> LoadAsync(string inputFile, CancellationToken ct)
    {
        await using var stream = File.OpenRead(inputFile);
        var episode = await JsonSerializer.DeserializeAsync<Episode>(stream, JsonOptions, ct)
                      ?? throw new InvalidDataException("JSON vazio.");

        // Reconstrói o dicionário com comparação case-insensitive (o deserializador cria um novo).
        episode.Speakers = new Dictionary<string, SpeakerDefinition>(episode.Speakers, StringComparer.OrdinalIgnoreCase);

        if (string.IsNullOrWhiteSpace(episode.Id))
            episode.Id = Path.GetFileNameWithoutExtension(inputFile);

        Validate(episode);
        return episode;
    }

    private static void Validate(Episode e)
    {
        var errors = new List<string>();
        if (e.Id.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0) errors.Add($"'id' contém caracteres inválidos: {e.Id}");
        if (string.IsNullOrWhiteSpace(e.Title)) errors.Add("'title' é obrigatório.");
        if (e.Speakers.Count == 0) errors.Add("'speakers' está vazio.");
        foreach (var (name, s) in e.Speakers)
            if (string.IsNullOrWhiteSpace(s.Voice)) errors.Add($"Speaker '{name}' sem 'voice'.");
        if (e.Segments.Count == 0) errors.Add("'segments' está vazio.");
        for (var i = 0; i < e.Segments.Count; i++)
        {
            var seg = e.Segments[i];
            if (!e.Speakers.ContainsKey(seg.Speaker)) errors.Add($"Segmento #{i + 1}: speaker '{seg.Speaker}' não definido.");
            if (string.IsNullOrWhiteSpace(seg.Text)) { errors.Add($"Segmento #{i + 1}: 'text' vazio."); continue; }
            if (e.Speakers.TryGetValue(seg.Speaker, out var sp))
            {
                try { SsmlBuilder.Build(e.Language, sp, seg); }
                catch (FormatException ex) { errors.Add($"Segmento #{i + 1}: {ex.Message}"); }
            }
        }
        if (errors.Count > 0)
            throw new InvalidDataException(string.Join(Environment.NewLine, errors.Select(x => "  - " + x)));
    }

    public async Task<EpisodeTranscript> GenerateAsync(Episode episode, CancellationToken ct)
    {
        var defaultPause = episode.DefaultPauseMs ?? settings.DefaultPauseMs;
        var lines = new List<TranscriptLine>();
        var tempPcm = Path.Combine(Path.GetTempPath(), $"fluentflow-{episode.Id}-{Guid.NewGuid():N}.pcm");

        try
        {
            await using (var pcm = File.Create(tempPcm))
            {
                WriteSilence(pcm, settings.LeadingSilenceMs);

                for (var i = 0; i < episode.Segments.Count; i++)
                {
                    var seg = episode.Segments[i];
                    var speaker = episode.Speakers[seg.Speaker];
                    var plain = SsmlBuilder.ToPlainText(seg.Text);
                    Console.Write($"    [{i + 1}/{episode.Segments.Count}] {seg.Speaker}: {Truncate(plain, 60)}");

                    var audio = await tts.SynthesizeAsync(episode.Language, speaker, seg, ct);
                    var startMs = (int)(pcm.Position / AzureTtsService.BytesPerMs);
                    await pcm.WriteAsync(audio, ct);
                    var endMs = (int)(pcm.Position / AzureTtsService.BytesPerMs);
                    Console.WriteLine($"  ({(endMs - startMs) / 1000.0:0.0}s)");

                    lines.Add(new TranscriptLine
                    {
                        Index = i,
                        Section = seg.Section,
                        Speaker = seg.Speaker,
                        Text = plain,
                        Translation = seg.Translation,
                        StartMs = startMs,
                        EndMs = endMs,
                    });

                    var isLast = i == episode.Segments.Count - 1;
                    WriteSilence(pcm, isLast ? settings.TrailingSilenceMs : seg.PauseAfterMs ?? defaultPause);
                }
            }

            var durationMs = (int)(new FileInfo(tempPcm).Length / AzureTtsService.BytesPerMs);

            var mp3Name = $"{episode.Id}.mp3";
            Console.WriteLine($"    → A codificar {mp3Name}");
            await encoder.EncodeAsync(tempPcm, Path.Combine(outputDir, mp3Name), episode, 1.0, ct);

            string? slowName = null;
            if (settings.GenerateSlowVersion)
            {
                slowName = $"{episode.Id}.slow.mp3";
                Console.WriteLine($"    → A codificar {slowName} (tempo {settings.SlowTempo:0.##}x)");
                await encoder.EncodeAsync(tempPcm, Path.Combine(outputDir, slowName), episode, settings.SlowTempo, ct);
            }

            var transcript = new EpisodeTranscript
            {
                Id = episode.Id,
                Title = episode.Title,
                Description = episode.Description,
                Language = episode.Language,
                Level = episode.Level,
                Series = episode.Series,
                Season = episode.Season,
                EpisodeNumber = episode.EpisodeNumber,
                DurationMs = durationMs,
                AudioFile = mp3Name,
                SlowAudioFile = slowName,
                SlowTempo = slowName is null ? null : settings.SlowTempo,
                GeneratedAtUtc = DateTimeOffset.UtcNow,
                Lines = lines,
            };

            var transcriptPath = Path.Combine(outputDir, $"{episode.Id}.json");
            await File.WriteAllTextAsync(transcriptPath, JsonSerializer.Serialize(transcript, JsonOptions), ct);
            return transcript;
        }
        finally
        {
            try { File.Delete(tempPcm); } catch { /* ignorar */ }
        }
    }

    private static void WriteSilence(Stream stream, int ms)
    {
        if (ms <= 0) return;
        stream.Write(new byte[ms * AzureTtsService.BytesPerMs]);
    }

    private static string Truncate(string s, int max)
    {
        s = s.ReplaceLineEndings(" ").Trim();
        return s.Length <= max ? s : s[..(max - 1)] + "…";
    }
}
