using System.Globalization;
using FluentFlow.Core.Common;
using FluentFlow.Web.Client;
using FluentFlow.Web.Client.Services;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;
using MudBlazor.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

var appSettings = new AppSettings();
builder.Configuration.Bind("AppSettings", appSettings);
builder.Services.AddSingleton(appSettings);

var apiBaseUrl = builder.Configuration["ApiBaseUrl"];

// ── Auth ──────────────────────────────────────────────────────────────────────
builder.Services.AddScoped<TokenAuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<TokenAuthStateProvider>());
builder.Services.AddAuthorizationCore();

// ── HTTP Client com handler JWT ───────────────────────────────────────────────
builder.Services.AddScoped<AuthorizationMessageHandler>();
builder.Services.AddHttpClient<ApiClient>(client => client.BaseAddress = new Uri(apiBaseUrl))
    .AddHttpMessageHandler<AuthorizationMessageHandler>();

// ── Services ──────────────────────────────────────────────────────────────────
builder.Services.AddScoped<WebAuthService>();

// ── MudBlazor ─────────────────────────────────────────────────────────────────
builder.Services.AddMudServices();

// ── Localização ──────────────────────────────────────────────────────────────
builder.Services.AddLocalization();
builder.Services.AddScoped<LanguageService>();

var factory = builder.Services.BuildServiceProvider().GetRequiredService<IStringLocalizerFactory>();
LocalizationHelper.Configure(factory);

var host = builder.Build();

// Restaurar idioma guardado antes do primeiro render
try
{
    var js = host.Services.GetRequiredService<IJSRuntime>();
    var saved = await js.InvokeAsync<string?>("localStorage.getItem", "ff_language");

    if (!string.IsNullOrEmpty(saved))
    {
        var culture = new CultureInfo(saved);
        CultureInfo.DefaultThreadCurrentCulture = culture;
        CultureInfo.DefaultThreadCurrentUICulture = culture;
    }
}
catch { /* usar pt como default */ }

await host.RunAsync();