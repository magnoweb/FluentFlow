using FluentFlow.Core.Interfaces;
using Microsoft.Extensions.Logging;
using PhoneticFlow;

namespace FluentFlow.Infrastructure.Services;

/// <summary>
/// Serviço de conversão fonética usando PhoneticFlow (Lytspel).
/// PhoneticConverter não é thread-safe — criado por chamada.
/// PhoneticDictionary.Shared é thread-safe e reutilizado.
/// </summary>
public class PhoneticService(ILogger<PhoneticService> logger) : IPhoneticService
{
    public string? Convert(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return null;

        try
        {
            // Criar por chamada — PhoneticConverter é stateful e não thread-safe
            // PhoneticDictionary.Shared é lazy e thread-safe — reutilizado entre chamadas
            var converter = new PhoneticConverter(PhoneticDictionary.Shared);
            var result    = converter.ConvertParagraph(text, testIfForeign: true);

            // ConvertParagraph devolve o texto original se parecer língua estrangeira
            // Nesse caso retornar null — o card não tem pronúncia fonética
            if (result == text)
            {
                logger.LogDebug($"PhoneticFlow: text not recognized as English — '{text}'");
                return null;
            }

            return result;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, $"PhoneticFlow: error during conversion '{text}'");
            return null;
        }
    }
}