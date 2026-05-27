namespace FluentFlow.Core.Interfaces;

public interface ISpeechToTextService
{
    Task<string> TranscribeAsync(string audioPath, string language = "en");
}