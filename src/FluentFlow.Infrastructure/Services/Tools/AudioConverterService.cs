using FluentFlow.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using NAudio.Wave;
using Xabe.FFmpeg;

namespace FluentFlow.Infrastructure.Services.Tools;

public class AudioConverterService : IAudioConverterService, IHostedService
{
    private readonly string _rootPath;
    private readonly string _ffmpegPath;
    private readonly ILogger<AudioConverterService> _logger;
    private bool _ffmpegAvailable;
    private bool _ready;

    // Formatos que o NAudio consegue converter sem FFmpeg
    private static readonly HashSet<string> NativeFormats = new(StringComparer.OrdinalIgnoreCase) { ".wav", ".mp3", ".aiff", ".aif" };

    // Formatos que requerem FFmpeg
    private static readonly HashSet<string> FfmpegFormats = new(StringComparer.OrdinalIgnoreCase) { ".m4a", ".ogg", ".flac", ".aac", ".wma", ".opus", ".webm" };

    public AudioConverterService( IConfiguration config, ILogger<AudioConverterService> logger)
    {
        _logger = logger;
        _rootPath = config["Storage:LocalPath"] ?? Path.Combine(Directory.GetCurrentDirectory(), "App_Data", "Uploads");
        _ffmpegPath = config["FFmpegPath"] ?? Path.Combine(AppContext.BaseDirectory, "ffmpeg");
    }

    // ── IHostedService ────────────────────────────────────────────────────────
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _ffmpegAvailable = await TryInitFfmpegAsync();

        if (_ffmpegAvailable)
            _logger.LogInformation("FFmpeg available in {Path}", _ffmpegPath);
        else
            _logger.LogWarning(
                "FFmpeg not available — formats {Formats} will not be supported. " +
                "Only {Native} will be converted via NAudio.",
                string.Join(", ", FfmpegFormats),
                string.Join(", ", NativeFormats));

        _ready = true;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;

    // ── Tentar inicializar FFmpeg ──────────────────────────────────────────────
    private async Task<bool> TryInitFfmpegAsync()
    {
        // 1. Verificar se já está no PATH do sistema
        if (IsInSystemPath("ffmpeg"))
        {
            FFmpeg.SetExecutablesPath("");
            return true;
        }

        // 2. Verificar se está na pasta configurada
        var ffmpegExe = Path.Combine(_ffmpegPath, OperatingSystem.IsWindows() ? "ffmpeg.exe" : "ffmpeg");

        if (File.Exists(ffmpegExe))
        {
            FFmpeg.SetExecutablesPath(_ffmpegPath);
            return true;
        }

        // 3. Tentar descarregar — se falhar, continuar sem FFmpeg
        try
        {
            Directory.CreateDirectory(_ffmpegPath);
            _logger.LogInformation("FFmpeg not found. Trying to download to {Path}...", _ffmpegPath);

            await Xabe.FFmpeg.Downloader.FFmpegDownloader
                .GetLatestVersion( Xabe.FFmpeg.Downloader.FFmpegVersion.Official, _ffmpegPath);

            FFmpeg.SetExecutablesPath(_ffmpegPath);
            _logger.LogInformation("FFmpeg successfully downloaded.");
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(
                "It was not possible to download FFmpeg: {Message}. " +
                "Continuing only with NAudio.",
                ex.Message);
            return false;
        }
    }

    private static bool IsInSystemPath(string executable)
    {
        try
        {
            var paths = Environment.GetEnvironmentVariable("PATH")?.Split(Path.PathSeparator) ?? [];
            var exeName = OperatingSystem.IsWindows() ? $"{executable}.exe" : executable;

            return paths.Any(p => File.Exists(Path.Combine(p, exeName)));
        }
        catch { return false; }
    }

    // ── IAudioConverterService ────────────────────────────────────────────────
    public async Task<string> ConvertToWavAsync(string inputPath)
    {
        if (!_ready)
            throw new InvalidOperationException("AudioConverterService has not started yet.");

        var fullInput = Path.IsPathRooted(inputPath) ? inputPath : Path.Combine(_rootPath, inputPath);

        if (!File.Exists(fullInput))
            throw new FileNotFoundException($"File not found: {fullInput}");

        var ext = Path.GetExtension(fullInput).ToLowerInvariant();

        _logger.LogInformation("To convert {File} ({Ext}) to 16kHz PCM WAV", Path.GetFileName(fullInput), ext);

        // Escolher estratégia de conversão
        if (NativeFormats.Contains(ext))
            return await ConvertWithNAudioAsync(fullInput);

        if (FfmpegFormats.Contains(ext) && _ffmpegAvailable)
            return await ConvertWithFfmpegAsync(fullInput);

        if (FfmpegFormats.Contains(ext) && !_ffmpegAvailable)
        {
            _logger.LogWarning(
                "{Ext} format requires FFmpeg (not available). " +
                "Trying conversion with NAudio as a fallback.", ext);
            // Tentar NAudio mesmo assim — pode funcionar para alguns .ogg/.flac
            try { return await ConvertWithNAudioAsync(fullInput); }
            catch
            {
                throw new NotSupportedException(
                    $"'{ext}' format not supported without FFmpeg. " +
                    "Upload in WAV or MP3.");
            }
        }

        throw new NotSupportedException($"Format '{ext}' not supported.");
    }

    // ── NAudio (sem dependências externas) ────────────────────────────────────
    private Task<string> ConvertWithNAudioAsync(string inputPath)
    {
        return Task.Run(() =>
        {
            var outputPath = Path.Combine(Path.GetTempPath(), $"ff_{Guid.NewGuid():N}.wav");

            try
            {
                using var reader = new AudioFileReader(inputPath);
                var targetFormat = new WaveFormat(16000, 16, 1);
                using var resampler = new MediaFoundationResampler(reader, targetFormat)
                {
                    ResamplerQuality = 60
                };
                WaveFileWriter.CreateWaveFile(outputPath, resampler);

                _logger.LogInformation("NAudio: conversion completed ({Size} KB)", new FileInfo(outputPath).Length / 1024);

                return outputPath;
            }
            catch (Exception ex)
            {
                if (File.Exists(outputPath))
                    File.Delete(outputPath);
                _logger.LogError(ex, "NAudio: failed to convert {Input}", inputPath);
                throw;
            }
        });
    }

    // ── FFmpeg ────────────────────────────────────────────────────────────────
    private async Task<string> ConvertWithFfmpegAsync(string inputPath)
    {
        var outputPath = Path.Combine(Path.GetTempPath(), $"ff_{Guid.NewGuid():N}.wav");

        try
        {
            await FFmpeg.Conversions.New()
                .AddParameter($"-i \"{inputPath}\"")
                .AddParameter("-ar 16000")
                .AddParameter("-ac 1")
                .AddParameter("-c:a pcm_s16le")
                .SetOutput(outputPath)
                .Start();

            _logger.LogInformation("FFmpeg: conversion completed ({Size} KB)", new FileInfo(outputPath).Length / 1024);

            return outputPath;
        }
        catch (Exception ex)
        {
            if (File.Exists(outputPath))
                File.Delete(outputPath);
            _logger.LogError(ex, "FFmpeg: failed to convert {Input}", inputPath);
            throw;
        }
    }
}

/*
using FluentFlow.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Xabe.FFmpeg;
using Xabe.FFmpeg.Downloader;

namespace FluentFlow.Infrastructure.Services.Tools;

public class AudioConverterService : IAudioConverterService, IHostedService
{
    private readonly string _rootPath;
    private readonly string _tempPath;
    private readonly string _ffmpegPath;
    private readonly ILogger<AudioConverterService> _logger;
    private bool _ready;

    public AudioConverterService(IConfiguration config, ILogger<AudioConverterService> logger)
    {
        _logger = logger;
        _rootPath = config["Storage:LocalPath"] ?? Path.Combine(Directory.GetCurrentDirectory(), "App_Data", "Uploads");
        _tempPath = config["Storage:TempPath"] ?? Path.Combine(Directory.GetCurrentDirectory(), "App_Data", "Temp");
        _ffmpegPath = config["FFmpegPath"] ?? Path.Combine(AppContext.BaseDirectory, "ffmpeg");
        
        if (!Directory.Exists(_tempPath))
            Directory.CreateDirectory(_tempPath);
    }

    // ── IHostedService — garante que os binários existem antes de processar ──
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        if (!Directory.Exists(_ffmpegPath))
            Directory.CreateDirectory(_ffmpegPath);

        var ffmpegExe  = Path.Combine(_ffmpegPath, "ffmpeg.exe");
        var ffprobeExe = Path.Combine(_ffmpegPath, "ffprobe.exe");

        if (!File.Exists(ffmpegExe) || !File.Exists(ffprobeExe))
        {
            _logger.LogInformation("FFmpeg not found in {Path}. Downloading...", _ffmpegPath);

            try
            {
                await FFmpegDownloader.GetLatestVersion(FFmpegVersion.Official, _ffmpegPath, new DownloadProgressHandler(_logger));
                _logger.LogInformation("FFmpeg downloaded successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to download FFmpeg.");
                throw; // impede o arranque da aplicação se FFmpeg não estiver disponível
            }
        }
        else
        {
            _logger.LogInformation("FFmpeg found in {Path}.", _ffmpegPath);
        }

        FFmpeg.SetExecutablesPath(_ffmpegPath);
        _ready = true;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;

    // ── IAudioConverterService ─────────────────────────────────────────────────
    public async Task<string> ConvertToWavAsync(string inputPath)
    {
        if (!_ready)
            throw new InvalidOperationException("FFmpeg is not ready yet.");

        var fullInput = Path.IsPathRooted(inputPath) ? inputPath : Path.Combine(_rootPath, inputPath);

        if (!File.Exists(fullInput))
            throw new FileNotFoundException($"Audio file not found: {fullInput}");

        var outputPath = Path.Combine(_tempPath, $"ff_{Guid.NewGuid():N}.wav");
        _logger.LogInformation("The converter: {Input} → {Output}", fullInput, outputPath);

        try
        {
            await FFmpeg.Conversions.New()
                .AddParameter($"-i \"{fullInput}\"")
                .AddParameter("-ar 16000")
                .AddParameter("-ac 1")
                .AddParameter("-c:a pcm_s16le")
                //.AddParameter("-y")
                .SetOutput(outputPath)
                .Start();

            _logger.LogInformation("Conversion completed ({Size} KB)", new FileInfo(outputPath).Length / 1024);

            return outputPath;
        }
        catch (Exception ex)
        {
            if (File.Exists(outputPath))
                File.Delete(outputPath);

            _logger.LogError(ex, "Conversion failure of {Input}", fullInput);
            throw;
        }
    }

    // ── Progress handler ───────────────────────────────────────────────────────
    private sealed class DownloadProgressHandler(ILogger logger) : IProgress<ProgressInfo>
    {
        private int _lastPercent = -1;

        public void Report(ProgressInfo value)
        {
            var percent = (int)(value.DownloadedBytes * 100.0 / value.TotalBytes);
            if (percent == _lastPercent || percent % 10 != 0) return;
            _lastPercent = percent;
            logger.LogInformation("Downloading FFmpeg... {Percent}%", percent);
        }
    }
}
*/