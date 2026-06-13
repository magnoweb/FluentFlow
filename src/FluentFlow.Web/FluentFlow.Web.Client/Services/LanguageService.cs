using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using System.Globalization;

namespace FluentFlow.Web.Client.Services;

public class LanguageService(IJSRuntime js, NavigationManager nav)
{
    private static readonly Dictionary<string, string> _languages = new()
    {
        { "pt", "🇵🇹 Português" },
        { "en", "🇬🇧 English" },
        { "es", "🇪🇸 Español" },
        { "fr", "🇫🇷 Français" }
    };

    public IReadOnlyDictionary<string, string> Available => _languages;

    public string Current => CultureInfo.CurrentUICulture.TwoLetterISOLanguageName;

    public async Task SetLanguageAsync(string cultureName)
    {
        // 1. Guardar no localStorage (persiste sem recarregar)
        await js.InvokeVoidAsync("localStorage.setItem", "ff_language", cultureName);

        // 2. Definir o cookie de cultura para o servidor
        //    (necessário para o RequestLocalizationMiddleware)
        await js.InvokeVoidAsync("eval", string.Format(
            "document.cookie = '.AspNetCore.Culture=c%3D{0}%7Cuic%3D{0};" +
            "path=/;max-age=31536000;SameSite=Lax'", cultureName));

        // 3. Alterar a cultura do processo WASM directamente
        //    sem recarregar a página
        var culture = new CultureInfo(cultureName);
        CultureInfo.DefaultThreadCurrentCulture = culture;
        CultureInfo.DefaultThreadCurrentUICulture = culture;

        // 4. Navegar para a mesma página para forçar re-render
        //    SEM forceLoad — permanece no WASM
        nav.NavigateTo(nav.Uri, forceLoad: true);
    }

    public async Task<string> GetSavedLanguageAsync()
    {
        try
        {
            var saved = await js.InvokeAsync<string>("localStorage.getItem", "ff_language");
            return saved ?? "pt";
        }
        catch
        {
            return "pt";
        }
    }
}