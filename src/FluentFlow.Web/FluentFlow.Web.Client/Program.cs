using FluentFlow.Web.Client;
using FluentFlow.Web.Client.Services;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using MudBlazor.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

var appSettings = new AppSettings();
builder.Configuration.Bind("AppSettings", appSettings);
builder.Services.AddSingleton(appSettings);

var apiBaseUrl = builder.Configuration["ApiBaseUrl"] ?? "https://localhost:7001/";

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

await builder.Build().RunAsync();