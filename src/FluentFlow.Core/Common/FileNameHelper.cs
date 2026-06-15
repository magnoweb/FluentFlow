using System.Text.RegularExpressions;

namespace FluentFlow.Core.Common;

public static class FileNameHelper
{
    private static readonly Regex _invalidChars = new(@"[^\w\-.]", RegexOptions.Compiled);
    private static readonly Regex _multipleHyphens = new(@"-{2,}", RegexOptions.Compiled);

    /// <summary>
    /// Sanitiza o nome do ficheiro:
    /// - Remove espaços (substitui por hífen)
    /// - Remove caracteres especiais
    /// - Colapsa hífens múltiplos
    /// - Converte para minúsculas
    /// ex: "019 and a moment.mp3" → "019-and-a-moment.mp3"
    /// </summary>
    public static string Sanitize(string fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName))
            return $"{Guid.NewGuid():N}";

        var name = Path.GetFileNameWithoutExtension(fileName);
        var ext = Path.GetExtension(fileName).ToLowerInvariant();

        // Substituir espaços e underscores por hífen
        name = name.Replace(' ', '-').Replace('_', '-');

        // Remover caracteres que não sejam letras, números, hífen ou ponto
        name = _invalidChars.Replace(name, "");

        // Colapsar hífens múltiplos
        name = _multipleHyphens.Replace(name, "-");

        // Remover hífens no início/fim
        name = name.Trim('-');

        // Fallback se ficou vazio
        if (string.IsNullOrWhiteSpace(name))
            name = Guid.NewGuid().ToString("N");

        return $"{name.ToLowerInvariant()}{ext}";
    }

    /// <summary>
    /// Gera nome único com prefixo Guid para evitar colisões.
    /// ex: "019 and a moment.mp3" → "a1b2c3d4_019-and-a-moment.mp3"
    /// </summary>
    public static string SanitizeUnique(string fileName)
    {
        var sanitized = Sanitize(fileName);
        var prefix = Guid.NewGuid().ToString("N")[..8]; // 8 chars
        return $"{prefix}_{sanitized}";
    }
}