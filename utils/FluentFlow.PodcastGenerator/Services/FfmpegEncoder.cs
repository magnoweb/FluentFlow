using System.Diagnostics;
using System.Globalization;
using System.Text;
using FluentFlow.PodcastGenerator.Models;

namespace FluentFlow.PodcastGenerator.Services;

/// <summary>Converte PCM bruto (s16le, 24 kHz, mono) em MP3 via FFmpeg.</summary>
public sealed class FfmpegEncoder(PodcastSettings settings)
{
    public async Task EnsureAvailableAsync(CancellationToken ct)
    {
        try
        {
            var (code, _) = await RunAsync(["-version"], ct);
            if (code != 0) throw new InvalidOperationException();
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            throw new InvalidOperationException(
                $"FFmpeg não encontrado em '{settings.FfmpegPath}'. Instala-o ou ajusta Podcast:FfmpegPath no appsettings.json.");
        }
    }

    public async Task EncodeAsync(string pcmFile, string mp3File, Episode episode, double tempo, CancellationToken ct)
    {
        var filters = new List<string>();
        if (Math.Abs(tempo - 1.0) > 0.001)
            filters.Add("atempo=" + tempo.ToString("0.###", CultureInfo.InvariantCulture));
        if (settings.Normalize)
            filters.Add("loudnorm=I=-16:TP=-1.5:LRA=11");

        var args = new List<string>
        {
            "-hide_banner", "-loglevel", "error", "-y",
            "-f", "s16le", "-ar", AzureTtsService.SampleRate.ToString(CultureInfo.InvariantCulture), "-ac", "1",
            "-i", pcmFile,
        };
        if (filters.Count > 0) { args.Add("-af"); args.Add(string.Join(',', filters)); }
        args.AddRange(
        [
            "-ar", "44100", "-ac", "1",
            "-codec:a", "libmp3lame", "-b:a", settings.Bitrate,
            "-id3v2_version", "3",
            "-metadata", $"title={episode.Title}",
            "-metadata", "artist=FluentFlow",
            "-metadata", "album=FluentFlow Podcast",
            "-metadata", $"language={episode.Language}",
            mp3File,
        ]);

        var (code, stderr) = await RunAsync(args, ct);
        if (code != 0)
            throw new InvalidOperationException($"FFmpeg falhou (código {code}): {stderr}");
    }

    private async Task<(int ExitCode, string StdErr)> RunAsync(IEnumerable<string> args, CancellationToken ct)
    {
        var psi = new ProcessStartInfo(settings.FfmpegPath)
        {
            RedirectStandardError = true,
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true,
            StandardErrorEncoding = Encoding.UTF8,
        };
        foreach (var a in args) psi.ArgumentList.Add(a);

        using var process = Process.Start(psi) ?? throw new InvalidOperationException("Não foi possível iniciar o FFmpeg.");
        var stderrTask = process.StandardError.ReadToEndAsync(ct);
        _ = process.StandardOutput.ReadToEndAsync(ct);
        await process.WaitForExitAsync(ct);
        return (process.ExitCode, (await stderrTask).Trim());
    }
}
