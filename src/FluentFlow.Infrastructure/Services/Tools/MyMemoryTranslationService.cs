using System.Net.Http.Json;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FluentFlow.Infrastructure.Services.Tools;

public class MyMemoryTranslationService(IHttpClientFactory httpClientFactory, FluentFlowDbContext db, ILogger<MyMemoryTranslationService> logger) : ITranslationService
{
    public async Task<string> TranslateAsync(string text, string from, string to)
    {
        if (string.IsNullOrWhiteSpace(text)) return text;

        // Verificar cache primeiro
        var cached = await db.TranslationCache
            .FirstOrDefaultAsync(t => t.SourceText == text
                                      && t.FromLanguage == from
                                      && t.ToLanguage == to);
        if (cached is not null)
        {
            logger.LogDebug("Cache hit para tradução: {Text}", text[..Math.Min(30, text.Length)]);
            return cached.TranslatedText;
        }

        // Chamar MyMemory API
        var client   = httpClientFactory.CreateClient("MyMemory");
        var langPair = $"{from}|{to}";
        var url      = $"?q={Uri.EscapeDataString(text)}&langpair={langPair}";

        var response = await client.GetFromJsonAsync<MyMemoryResponse>(url);
        var translated = response?.ResponseData?.TranslatedText ?? text;

        // Guardar no cache
        db.TranslationCache.Add(new Core.Entities.TranslationCache
        {
            SourceText     = text,
            TranslatedText = translated,
            FromLanguage   = from,
            ToLanguage     = to,
        });
        await db.SaveChangesAsync();

        return translated;
    }

    private sealed record MyMemoryResponse(ResponseData? ResponseData);
    private sealed record ResponseData(string TranslatedText);
}