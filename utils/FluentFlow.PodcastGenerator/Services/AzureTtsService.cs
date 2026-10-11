using System.Security.Cryptography;
using System.Text;
using FluentFlow.PodcastGenerator.Models;
using Microsoft.CognitiveServices.Speech;

namespace FluentFlow.PodcastGenerator.Services;

/// <summary>
/// Sintetiza uma fala via Azure AI Speech e devolve PCM 16-bit mono 24 kHz (sem cabeçalho).
/// Resultados ficam em cache em disco para não gastar a quota gratuita em re-execuções.
/// </summary>
public sealed class AzureTtsService : IDisposable
{
    public const int SampleRate = 24_000;
    public const int BytesPerMs = SampleRate * 2 / 1000; // 16-bit mono → 48 bytes/ms

    private readonly SpeechSynthesizer _synthesizer;
    private readonly string _cacheDir;

    public int CharactersSynthesized { get; private set; }
    public int CacheHits { get; private set; }

    public AzureTtsService(AzureSpeechSettings settings, string cacheDir)
    {
        if (string.IsNullOrWhiteSpace(settings.Key))
            throw new InvalidOperationException(
                "Chave Azure Speech em falta. Define AzureSpeech:Key em appsettings.Development.json, ou com:\n" +
                "  dotnet user-secrets set \"AzureSpeech:Key\" \"<chave>\"\n" +
                "ou a variável de ambiente AzureSpeech__Key.");

        var config = SpeechConfig.FromSubscription(settings.Key, settings.Region);
        config.SetSpeechSynthesisOutputFormat(SpeechSynthesisOutputFormat.Raw24Khz16BitMonoPcm);

        // AudioConfig nulo → o áudio fica só em memória (não toca nas colunas).
        _synthesizer = new SpeechSynthesizer(config, null as Microsoft.CognitiveServices.Speech.Audio.AudioConfig);
        _cacheDir = cacheDir;
        Directory.CreateDirectory(_cacheDir);
    }

    public async Task<byte[]> SynthesizeAsync(string language, SpeakerDefinition speaker, Segment segment, CancellationToken ct)
    {
        var ssml = SsmlBuilder.Build(language, speaker, segment);
        var cacheFile = Path.Combine(_cacheDir, Hash(ssml) + ".pcm");

        if (File.Exists(cacheFile))
        {
            CacheHits++;
            return await File.ReadAllBytesAsync(cacheFile, ct);
        }

        using var result = await _synthesizer.SpeakSsmlAsync(ssml);

        if (result.Reason == ResultReason.Canceled)
        {
            var details = SpeechSynthesisCancellationDetails.FromResult(result);
            throw new InvalidOperationException(
                $"Azure TTS cancelado ({details.Reason}/{details.ErrorCode}): {details.ErrorDetails}");
        }

        if (result.Reason != ResultReason.SynthesizingAudioCompleted)
            throw new InvalidOperationException($"Azure TTS devolveu estado inesperado: {result.Reason}");

        var audio = result.AudioData;
        CharactersSynthesized += SsmlBuilder.ToPlainText(segment.Text).Length;
        await File.WriteAllBytesAsync(cacheFile, audio, ct);
        return audio;
    }

    private static string Hash(string value) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value)))[..32].ToLowerInvariant();

    public void Dispose() => _synthesizer.Dispose();
}
