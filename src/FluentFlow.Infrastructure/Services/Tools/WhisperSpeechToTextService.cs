using FluentFlow.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Whisper.net;

namespace FluentFlow.Infrastructure.Services.Tools;

public class WhisperSpeechToTextService(IConfiguration config, ILogger<WhisperSpeechToTextService> logger) : ISpeechToTextService, IDisposable
{
    private WhisperFactory? _factory;
    private readonly SemaphoreSlim _semaphore = new(1, 1); // Whisper não é thread-safe
    private bool _initialized;

    private async Task EnsureInitializedAsync()
    {
        if (_initialized) return;

        await _semaphore.WaitAsync();
        try
        {
            if (_initialized) return;

            var modelPath = config["Whisper:ModelPath"]
                ?? throw new InvalidOperationException("Whisper:ModelPath não configurado.");

            if (!File.Exists(modelPath))
                throw new FileNotFoundException($"Modelo Whisper não encontrado: {modelPath}");

            _factory     = WhisperFactory.FromPath(modelPath);
            _initialized = true;

            logger.LogInformation("Whisper.net inicializado com modelo: {Path}", modelPath);
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public async Task<string> TranscribeAsync(string audioPath, string language = "en")
    {
        await EnsureInitializedAsync();

        if (!File.Exists(audioPath))
            throw new FileNotFoundException($"Ficheiro de áudio não encontrado: {audioPath}");

        await _semaphore.WaitAsync();
        try
        {
            using var processor = _factory!.CreateBuilder().WithLanguage(language).Build();

            var segments = new List<string>();

            await using var fileStream = File.OpenRead(audioPath);
            await foreach (var segment in processor.ProcessAsync(fileStream))
                segments.Add(segment.Text);

            var result = string.Join(" ", segments).Trim();
            logger.LogInformation("Transcrição concluída: {Chars} caracteres", result.Length);
            return result;
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public void Dispose()
    {
        _factory?.Dispose();
        _semaphore.Dispose();
    }
}