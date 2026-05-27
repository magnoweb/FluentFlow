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
        Directory.CreateDirectory(_ffmpegPath);

        var ffmpegExe  = Path.Combine(_ffmpegPath, "ffmpeg.exe");
        var ffprobeExe = Path.Combine(_ffmpegPath, "ffprobe.exe");

        if (!File.Exists(ffmpegExe) || !File.Exists(ffprobeExe))
        {
            _logger.LogInformation("FFmpeg não encontrado em {Path}. A descarregar...", _ffmpegPath);

            try
            {
                await FFmpegDownloader.GetLatestVersion(FFmpegVersion.Official, _ffmpegPath, new DownloadProgressHandler(_logger));
                _logger.LogInformation("FFmpeg descarregado com sucesso.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Falha ao descarregar FFmpeg.");
                throw; // impede o arranque da aplicação se FFmpeg não estiver disponível
            }
        }
        else
        {
            _logger.LogInformation("FFmpeg encontrado em {Path}.", _ffmpegPath);
        }

        FFmpeg.SetExecutablesPath(_ffmpegPath);
        _ready = true;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;

    // ── IAudioConverterService ─────────────────────────────────────────────────
    public async Task<string> ConvertToWavAsync(string inputPath)
    {
        if (!_ready)
            throw new InvalidOperationException("FFmpeg ainda não está pronto.");

        var fullInput = Path.IsPathRooted(inputPath) ? inputPath : Path.Combine(_rootPath, inputPath);

        if (!File.Exists(fullInput))
            throw new FileNotFoundException($"Ficheiro de áudio não encontrado: {fullInput}");

        var outputPath = Path.Combine(_tempPath, $"ff_{Guid.NewGuid():N}.wav");
        _logger.LogInformation("A converter: {Input} → {Output}", fullInput, outputPath);

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

            _logger.LogInformation("Conversão concluída ({Size} KB)", new FileInfo(outputPath).Length / 1024);

            return outputPath;
        }
        catch (Exception ex)
        {
            if (File.Exists(outputPath))
                File.Delete(outputPath);

            _logger.LogError(ex, "Falha na conversão de {Input}", fullInput);
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
            logger.LogInformation("A descarregar FFmpeg... {Percent}%", percent);
        }
    }
}