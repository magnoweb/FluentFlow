using FluentFlow.Core.Interfaces;
using Microsoft.Extensions.Logging;
using PhoneticFlow;

namespace FluentFlow.Infrastructure.Services;

/// <summary>
/// Serviço de conversão fonética usando PhoneticFlow.
/// Suporta EN (Lytspel/dicionário), PT, ES, FR (G2P rule-based).
/// PhoneticConverter não é thread-safe — criado por chamada.
/// PhoneticDictionary.Shared é thread-safe — reutilizado entre chamadas EN.
/// </summary>
public class PhoneticService(ILogger<PhoneticService> logger) : IPhoneticService
{
    public string? Convert(string text, string language)
    {
        if (string.IsNullOrWhiteSpace(text))     return null;
        if (string.IsNullOrWhiteSpace(language)) return null;

        try
        {
            var engine = ResolveEngine(language);
            if (engine is null)
            {
                logger.LogDebug($"PhoneticFlow: idioma '{language}' não suportado.");
                return null;
            }

            var converter = new PhoneticConverter(engine);
            var result = converter.Convert(text);

            // Para inglês, ConvertParagraph pode retornar o original
            // se o texto parecer estrangeiro
            if (result == text)
            {
                logger.LogDebug(
                    "PhoneticFlow: texto não convertido para '{Language}' — '{Preview}'",
                    language,
                    text.Length > 60 ? text[..60] + "..." : text);
                return null;
            }

            return result;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex,
                "PhoneticFlow: erro ao converter para '{Language}' — '{Preview}'",
                language,
                text.Length > 60 ? text[..60] + "..." : text);
            return null;
        }
    }

    /// <summary>
    /// Mapeia o código de idioma (BCP-47 ou ISO 639-1) para o engine correcto.
    /// Retorna null para idiomas não suportados.
    /// </summary>
    private static IPhoneticEngine? ResolveEngine(string language)
    {
        // Normalizar: "en-US", "en_US", "EN" → "en"
        var lang = language.Split('-', '_')[0].ToLowerInvariant();

        return lang switch
        {
            "en" => PhoneticEngineFactory.Create(Language.English), // English — dicionário Lytspel
            "pt" => PhoneticEngineFactory.Create(Language.Portuguese),
            "es" => PhoneticEngineFactory.Create(Language.Spanish),
            "fr" => PhoneticEngineFactory.Create(Language.French),
            _    => null,
        };
    }
}