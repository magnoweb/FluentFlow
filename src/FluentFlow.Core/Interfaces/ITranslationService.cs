namespace FluentFlow.Core.Interfaces;

public interface ITranslationService
{
    Task<string> TranslateAsync(string text, string from, string to);
}