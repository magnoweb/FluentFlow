using FluentFlow.Web.Client.Services;
using FluentFlow.Web.Components;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Components.Authorization;
using MudBlazor.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents()
    .AddInteractiveWebAssemblyComponents();

builder.Services.AddMudServices();

// Configura um scheme de cookie como default para o servidor.
// Necessário para o pipeline HTTP não lançar "No DefaultChallengeScheme"
// quando encontra rotas com [Authorize] antes do WASM arrancar.
// O cookie nunca é emitido — a autenticação real é feita pelo JWT no WASM.
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        // Redirecionar para a SPA em vez de lançar excepção
        options.LoginPath    = "/login";
        options.LogoutPath   = "/login";
        options.AccessDeniedPath = "/login";
        // Cookie curto — não é para ser usado de facto
        options.ExpireTimeSpan = TimeSpan.FromMinutes(1);
        options.SlidingExpiration = false;
    });
builder.Services.AddAuthorizationCore();

// Serviços partilhados (servidor + WASM)
var apiBaseUrl = builder.Configuration["ApiBaseUrl"] ?? "https://localhost:7001/";
builder.Services.AddScoped<TokenAuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<TokenAuthStateProvider>());
builder.Services.AddScoped<AuthorizationMessageHandler>();
builder.Services.AddHttpClient<ApiClient>(client => client.BaseAddress = new Uri(apiBaseUrl)).AddHttpMessageHandler<AuthorizationMessageHandler>();

builder.Services.AddScoped<WebAuthService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
    app.UseWebAssemblyDebugging();
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();

// Ordem importante — Authentication antes de Authorization
app.UseAuthentication();
app.UseAuthorization();

app.UseAntiforgery();
app.MapStaticAssets();

// Servir ficheiros de áudio
var uploadsPath = Path.Combine(builder.Environment.ContentRootPath, "App_Data", "Uploads");
Directory.CreateDirectory(uploadsPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsPath),
    RequestPath  = "/uploads"
});

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode()
    .AddInteractiveWebAssemblyRenderMode()
    .AddAdditionalAssemblies(typeof(FluentFlow.Web.Client._Imports).Assembly);

app.Run();