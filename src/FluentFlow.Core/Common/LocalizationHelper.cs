using FluentFlow.Core.Resources;
using Microsoft.Extensions.Localization;

namespace FluentFlow.Core.Common;

/// <summary>
/// Helper estático para acesso a traduções fora do contexto de injecção.
/// Configurado uma vez no arranque da aplicação.
/// Usado em métodos de extensão, classes estáticas e qualquer lugar
/// onde o IStringLocalizer não pode ser injectado directamente.
/// </summary>
public static class LocalizationHelper
{
    private static IStringLocalizer? _localizer;

    /// <summary>
    /// Configura o helper com a factory de localização.
    /// Deve ser chamado no Program.cs antes de RunAsync().
    /// </summary>
    public static void Configure(IStringLocalizerFactory factory)
    {
        _localizer = factory.Create(typeof(App));
    }

    /// <summary>
    /// Obtém a tradução para a chave especificada.
    /// Retorna a chave como fallback se não configurado ou não encontrado.
    /// </summary>
    public static string Get(string key)
    {
        if (_localizer is null) return key;
        var value = _localizer[key];
        return value.ResourceNotFound ? key : value.Value;
    }

    /// <summary>
    /// Obtém a tradução com argumentos de formatação.
    /// </summary>
    public static string Get(string key, params object[] args)
    {
        if (_localizer is null) return string.Format(key, args);
        var value = _localizer[key, args];
        return value.ResourceNotFound ? string.Format(key, args) : value.Value;
    }

    /// <summary>
    /// Indexador — permite usar como LocalizationHelper.T["chave"]
    /// </summary>
    public static string T(string key) => Get(key);
    public static string T(string key, params object[] args) => Get(key, args);

    /// <summary>
    /// Verifica se o helper está configurado.
    /// </summary>
    public static bool IsConfigured => _localizer is not null;

    /// <summary>
    /// Traduz mensagens de erro vindas da API.
    /// Tenta encontrar uma chave Api.{mensagem normalizada},
    /// retornando a mensagem original como fallback.
    /// </summary>
    public static string TranslateApiError(string? apiMessage)
    {
        if (string.IsNullOrWhiteSpace(apiMessage))
            return Get("Api.GenericError");

        // Tentar mapeamento directo por chave normalizada
        var key = NormalizeToKey(apiMessage);
        if (_localizer is not null)
        {
            var attempt = _localizer[$"Api.{key}"];
            if (!attempt.ResourceNotFound) return attempt.Value;
        }

        // Fallback — retornar mensagem original da API
        return apiMessage;
    }

    // Normaliza uma mensagem de erro para formato de chave
    // ex: "Deck não encontrado." → "DeckNotFound"
    private static string NormalizeToKey(string message)
    {
        // Mapeamento explícito das mensagens conhecidas da API
        return message.Trim().TrimEnd('.') switch
        {
            "Deck não encontrado" or "Deck not found" => "DeckNotFound",
            "Card não encontrado" or "Card not found" => "CardNotFound",
            "Sessão não encontrada" or "Session not found" => "SessionNotFound",
            "Utilizador não encontrado" or "User not found" => "UserNotFound",
            "Email ou password incorrectos" or "Incorrect email or password" => "InvalidCredentials",
            "Este email já está em uso" or "This email is already in use" => "EmailAlreadyInUse",
            "Password actual incorrecta" or "Current password is incorrect" => "CurrentPasswordWrong",
            "Áudio não fornecido" or "Audio not provided" => "AudioNotProvided",
            "Nenhum ficheiro enviado" or "No files uploaded" => "NoFilesUploaded",
            "Erro na transcrição. Tente novamente." or "Transcription error. Please try again." => "TranscriptionError",
            _ => "GenericError",
        };
    }
}