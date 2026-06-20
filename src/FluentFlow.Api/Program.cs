using System.Text;
using FluentFlow.Api.Extensions;
using FluentFlow.Api.Hubs;
using FluentFlow.Api.Validators;
using FluentFlow.Core.Common;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using FluentFlow.Infrastructure.Identity;
using FluentFlow.Infrastructure.Services;
using FluentFlow.Infrastructure.Services.Tools;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using Serilog;
using Serilog.Events;
using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Localization;

// ── Serilog bootstrap ─────────────────────────────────────────────────────────
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.DataProtection", LogEventLevel.Error)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithThreadId()
    .WriteTo.Console()
    .CreateBootstrapLogger();

var builder = WebApplication.CreateBuilder(args);
var config  = builder.Configuration;

var connectionString = "Development".Equals(config["Environment"], StringComparison.InvariantCultureIgnoreCase) ? "local" : "online";

builder.Services.AddSingleton<IConfiguration>(config);

// ── Serilog ───────────────────────────────────────────────────────────────────
builder.SerilogConfig(config);

// ── Data Protection ──────────────────────────────────────────────────────────
var keysFolder = Path.Combine(builder.Environment.ContentRootPath, "App_Data", "Keys");
Directory.CreateDirectory(keysFolder);

builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(keysFolder))
    .SetApplicationName("FluentFlow");

// ── Database ──────────────────────────────────────────────────────────────────
builder.Services.AddDbContext<FluentFlowDbContext>(options =>
    options.UseSqlServer(config.GetConnectionString(connectionString),
        sql => sql.MigrationsAssembly("FluentFlow.Infrastructure")));

// ── Identity ──────────────────────────────────────────────────────────────────
builder.Services.AddIdentity<ApplicationUser, IdentityRole<Guid>>(options =>
{
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = false;
    options.User.RequireUniqueEmail = true;
    options.SignIn.RequireConfirmedEmail = false;
})
.AddEntityFrameworkStores<FluentFlowDbContext>()
.AddDefaultTokenProviders();

// ── Authentication — JWT + Social ─────────────────────────────────────────────
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = config["Jwt:Issuer"],
        ValidAudience = config["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["Jwt:Key"]!)), ClockSkew = TimeSpan.Zero
    };

    // SignalR — token via query string
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = ctx =>
        {
            var accessToken = ctx.Request.Query["access_token"];
            var path = ctx.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                ctx.Token = accessToken;
            return Task.CompletedTask;
        }
    };
})
.AddGoogle(options =>
{
    options.ClientId = config["Auth:Google:ClientId"]!;
    options.ClientSecret = config["Auth:Google:ClientSecret"]!;
    options.CallbackPath = "/signin-google";
})
.AddMicrosoftAccount(options =>
{
    options.ClientId = config["Auth:Microsoft:ClientId"]!;
    options.ClientSecret = config["Auth:Microsoft:ClientSecret"]!;
    options.CallbackPath = "/signin-microsoft";
})
.AddGitHub(options =>
{
    options.ClientId = config["Auth:GitHub:ClientId"]!;
    options.ClientSecret = config["Auth:GitHub:ClientSecret"]!;
    options.CallbackPath = "/signin-github";
});

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.Requirements.Add(new AdminRequirement()));
});
builder.Services.AddSingleton<IAuthorizationHandler, AdminHandler>();

// ── Controllers + OpenAPI ─────────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// ── Proxy reverso (hosting compartilhado / IIS / nginx) ──────────────────────
// Necessário para que Url.Action() gere URLs com https em vez de http
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders =
        Microsoft.AspNetCore.HttpOverrides.ForwardedHeaders.XForwardedFor |
        Microsoft.AspNetCore.HttpOverrides.ForwardedHeaders.XForwardedProto;

    // Confiar em qualquer proxy (hosting compartilhado não tem IP fixo)
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

// ── CORS ──────────────────────────────────────────────────────────────────────
var allowedOrigins = config.GetSection("AllowedOrigins").Get<string[]>() ?? [];
var allowedOriginsDev = config.GetSection("AllowedOriginsDev").Get<string[]>() ?? [];
var allowAllDev = config.GetValue<bool>("AllowAllOriginsDev");
var allowLocalDev = config.GetValue<bool>("AllowLocalDev");

builder.Services.AddCors(options =>
{
    options.AddPolicy("FluentFlowPolicy", policy =>
    {
        if (allowAllDev && builder.Environment.IsDevelopment())
        {
            // Cenário 1 — Desenvolvimento local completo
            policy.SetIsOriginAllowed(_ => true)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        }
        else if (allowLocalDev)
        {
            // Cenário 2 — Web em localhost apontando para API em produção
            var origins = allowedOrigins
                .Concat(allowedOriginsDev)
                .Distinct()
                .ToArray();

            policy.WithOrigins(origins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials()
                  .WithExposedHeaders("Content-Disposition", "X-Pagination", "X-Total-Count");
        }
        else
        {
            // Cenário 3 — Produção normal
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials()
                  .WithExposedHeaders("Content-Disposition", "X-Pagination", "X-Total-Count");
        }
    });

    // Scalar/Swagger e endpoints públicos
    options.AddPolicy("PublicPolicy", policy =>
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod());
});

// ── Localização ───────────────────────────────────────────────────────────────
// Recursos estão em FluentFlow.Core — sem ResourcesPath local
builder.Services.AddLocalization();

var supportedCultures = new[]
{
    new CultureInfo("pt"),
    new CultureInfo("en"),
    new CultureInfo("es"),
    new CultureInfo("fr"),
};

builder.Services.Configure<RequestLocalizationOptions>(options =>
{
    options.DefaultRequestCulture = new RequestCulture("en");
    options.SupportedCultures = supportedCultures;
    options.SupportedUICultures = supportedCultures;
    options.RequestCultureProviders =
    [
        new CookieRequestCultureProvider(),
        new AcceptLanguageHeaderRequestCultureProvider(),
    ];
});

// ── Application Services ──────────────────────────────────────────────────────
builder.Services.AddScoped<IDeckService, DeckService>();
builder.Services.AddScoped<ICardService, CardService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IStudySchedulerService, StudySchedulerService>();
builder.Services.AddScoped<IStudySessionService, StudySessionService>();
builder.Services.AddScoped<IAudioBatchService, AudioBatchService>();
builder.Services.AddScoped<ILogService, LogService>();
builder.Services.AddScoped<IAdminService, AdminService>();

// ── FluentValidation ──────────────────────────────────────────────────────────
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<CreateDeckValidator>();

// ── Storage ───────────────────────────────────────────────────────────────────
builder.Services.AddScoped<IStorageService, LocalStorageService>();

// ── Speech-to-Text (Whisper — singleton: modelo carregado uma vez) ────────────
builder.Services.AddSingleton<ISpeechToTextService, WhisperSpeechToTextService>();

// ── Tradução ──────────────────────────────────────────────────────────────────
builder.Services.AddHttpClient("MyMemory", client =>
{
    client.BaseAddress = new Uri("https://api.mymemory.translated.net/get");
    client.Timeout     = TimeSpan.FromSeconds(10);
});
builder.Services.AddScoped<ITranslationService, MyMemoryTranslationService>();

// ── SignalR ───────────────────────────────────────────────────────────────────
builder.Services.AddSingleton<IUserIdProvider, NameIdentifierUserIdProvider>();
builder.Services.AddSignalR();

// ── AudioBatchProcessor ───────────────────────────────────────────────────────
builder.Services.AddSingleton<AudioBatchProcessor>();
builder.Services.AddHostedService(sp => sp.GetRequiredService<AudioBatchProcessor>());
builder.Services.AddScoped<IBatchProgressNotifier, SignalRBatchProgressNotifier>();
builder.Services.AddSingleton<AudioConverterService>();
builder.Services.AddSingleton<IAudioConverterService>(sp => sp.GetRequiredService<AudioConverterService>());
builder.Services.AddHostedService(sp => sp.GetRequiredService<AudioConverterService>());

// ── Auth Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// ══════════════════════════════════════════════════════════════════════════════
var app = builder.Build();
// ══════════════════════════════════════════════════════════════════════════════

// ── Proxy reverso (hosting compartilhado / IIS / nginx) ──────────────────────
app.UseForwardedHeaders();

// ── Serilog ───────────────────────────────────────────────────────────────────
app.SerilogUse();

// ── LocalizationHelper — configurar antes de qualquer uso ─────────────────────
var localizerFactory = app.Services.GetRequiredService<IStringLocalizerFactory>();
LocalizationHelper.Configure(localizerFactory);

// ── Migrations automáticas ────────────────────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<FluentFlowDbContext>();
    await db.Database.MigrateAsync();
}

// ── OpenAPI / Scalar ──────────────────────────────────────────────────────────
app.MapOpenApi();
app.MapScalarApiReference(options =>
{
    options.Title = "FluentFlow API";
    options.Theme = ScalarTheme.DeepSpace;
})
.RequireCors("PublicPolicy");

// ── Pipeline — ordem correcta ─────────────────────────────────────────────────
app.UseHttpsRedirection(); // 1. HTTPS redirect primeiro

app.UseStaticFiles(new StaticFileOptions // 2. Ficheiros estáticos
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(
        Path.Combine(builder.Environment.ContentRootPath, "App_Data", "Uploads")),
    RequestPath = "/uploads"
});

// Garantir que a pasta existe
Directory.CreateDirectory(Path.Combine(builder.Environment.ContentRootPath, "App_Data", "Uploads"));

app.UseRouting(); // 3. Routing antes de CORS
app.UseRequestLocalization(); // 4. Localização
app.UseCors("FluentFlowPolicy"); // 5. CORS após routing
app.UseAuthentication(); // 6. Autenticação
app.UseAuthorization(); // 7. Autorização

app.MapControllers();

// ── SignalR ───────────────────────────────────────────────────────────────────
app.MapHub<BatchProgressHub>("/hubs/batch");

app.Run();