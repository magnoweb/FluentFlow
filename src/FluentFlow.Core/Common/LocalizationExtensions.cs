namespace FluentFlow.Core.Common;

public static class LocalizationExtensions
{
    /// <summary>
    /// Traduz o modo de estudo para o idioma actual.
    /// </summary>
    public static string GetModeLabel(this string mode, bool displayIcon = false)
    {
        if (!LocalizationHelper.IsConfigured) return mode;

        return mode switch
        {
            "Listening" => displayIcon
                ? $"🎧 {LocalizationHelper.Get("Study.Listening")}"
                : LocalizationHelper.Get("Study.Listening"),
            "Speaking" => displayIcon
                ? $"🗣️ {LocalizationHelper.Get("Study.Speaking")}"
                : LocalizationHelper.Get("Study.Speaking"),
            _ => mode
        };
    }

    /// <summary>
    /// Traduz o nível CEFR para o idioma actual.
    /// </summary>
    public static string GetCefrLabel(this string? level) => level is null ? "—" : LocalizationHelper.Get($"Cefr.{level}");

    /// <summary>
    /// Traduz o score SM-2 para o idioma actual.
    /// </summary>
    public static string GetScoreLabel(this int score) => LocalizationHelper.Get($"Study.Score{score}");

    /// <summary>
    /// Traduz uma mensagem de erro da API.
    /// </summary>
    public static string TranslateError(this string? message) => LocalizationHelper.TranslateApiError(message);
}