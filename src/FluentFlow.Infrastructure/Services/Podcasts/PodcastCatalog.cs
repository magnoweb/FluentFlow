using System.Globalization;
using System.Text.Json;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Infrastructure.Services.Podcasts;

/// <summary>Transcrição lida do {id}.json gerado pelo FluentFlow.PodcastGenerator.</summary>
public sealed record PodcastTranscript(
    string Id,
    string Title,
    string? Description,
    string Language,
    string? Level,
    string? Series,
    int? Season,
    int? EpisodeNumber,
    int DurationMs,
    string? AudioFile,
    string? SlowAudioFile,
    double? SlowTempo,
    DateTime GeneratedAtUtc,
    IReadOnlyList<PodcastLineDto> Lines);

/// <summary>Regras partilhadas dos podcasts: agrupamento por série e leitura das transcrições.</summary>
public static class PodcastCatalog
{
    public const string GeneralGroupKey = "general";

    private static readonly JsonSerializerOptions ReadOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
    };

    internal static readonly JsonSerializerOptions StoreOptions = new(JsonSerializerDefaults.Web);

    /// <summary>Chave do grupo: série+temporada, ou "general".</summary>
    public static string GroupKey(string? series, int? season) =>
        string.IsNullOrWhiteSpace(series) ? GeneralGroupKey : $"{Slug(series)}-s{season ?? 1:00}";

    /// <summary>Lê e valida a transcrição. Devolve null se o JSON não for uma transcrição do gerador.</summary>
    public static async Task<PodcastTranscript?> ParseAsync(Stream json, string fallbackId)
    {
        TranscriptFile? t;
        try
        {
            t = await JsonSerializer.DeserializeAsync<TranscriptFile>(json, ReadOptions);
        }
        catch (JsonException)
        {
            return null;
        }

        if (t?.Lines is null || t.Lines.Count == 0) return null;

        var lines = t.Lines
            .OrderBy(l => l.Index)
            .Select(l => new PodcastLineDto(l.Index, l.Section, l.Speaker ?? "", l.Text ?? "", l.Translation, l.StartMs, l.EndMs))
            .ToList();

        var id = Slug(string.IsNullOrWhiteSpace(t.Id) ? fallbackId : t.Id);
        if (id.Length == 0) id = Guid.NewGuid().ToString("N");
        if (id.Length > 100) id = id[..100];

        var duration = t.DurationMs > 0 ? t.DurationMs : lines.Max(l => l.EndMs);

        return new PodcastTranscript(
            id,
            Truncate(string.IsNullOrWhiteSpace(t.Title) ? id : t.Title.Trim(), 200)!,
            Truncate(t.Description?.Trim(), 1000),
            Truncate(string.IsNullOrWhiteSpace(t.Language) ? "en-US" : t.Language.Trim(), 20)!,
            Truncate(t.Level?.Trim(), 20),
            Truncate(string.IsNullOrWhiteSpace(t.Series) ? null : t.Series.Trim(), 200),
            t.Season,
            t.EpisodeNumber,
            duration,
            t.AudioFile,
            t.SlowAudioFile,
            t.SlowTempo,
            t.GeneratedAtUtc == default ? DateTime.UtcNow : t.GeneratedAtUtc.UtcDateTime,
            lines);
    }

    public static string SerializeLines(IReadOnlyList<PodcastLineDto> lines) =>
        JsonSerializer.Serialize(lines, StoreOptions);

    public static IReadOnlyList<PodcastLineDto> DeserializeLines(string json)
    {
        try
        {
            return JsonSerializer.Deserialize<List<PodcastLineDto>>(json, StoreOptions) ?? [];
        }
        catch (JsonException)
        {
            return [];
        }
    }

    internal static string Slug(string value)
    {
        var chars = value.Trim().ToLower(CultureInfo.InvariantCulture)
            .Select(c => char.IsLetterOrDigit(c) ? c : '-').ToArray();
        return string.Join('-', new string(chars).Split('-', StringSplitOptions.RemoveEmptyEntries));
    }

    private static string? Truncate(string? value, int max) =>
        value is null ? null : value.Length <= max ? value : value[..max];

    // Formato de Output/{id}.json do FluentFlow.PodcastGenerator
    private sealed class TranscriptFile
    {
        public string? Id { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? Language { get; set; }
        public string? Level { get; set; }
        public string? Series { get; set; }
        public int? Season { get; set; }
        public int? EpisodeNumber { get; set; }
        public int DurationMs { get; set; }
        public string? AudioFile { get; set; }
        public string? SlowAudioFile { get; set; }
        public double? SlowTempo { get; set; }
        public DateTimeOffset GeneratedAtUtc { get; set; }
        public List<TranscriptLine>? Lines { get; set; }
    }

    private sealed class TranscriptLine
    {
        public int Index { get; set; }
        public string? Section { get; set; }
        public string? Speaker { get; set; }
        public string? Text { get; set; }
        public string? Translation { get; set; }
        public int StartMs { get; set; }
        public int EndMs { get; set; }
    }
}
