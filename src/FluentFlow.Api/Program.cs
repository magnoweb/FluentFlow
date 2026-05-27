using System.Text;
using FluentFlow.Api.Extensions;
using FluentFlow.Api.Hubs;
using FluentFlow.Api.Validators;
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
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using Serilog;
using Serilog.Events;

// ── Serilog —─────────────────────────────────────
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithThreadId()
    .WriteTo.Console()
    .CreateBootstrapLogger();

var builder = WebApplication.CreateBuilder(args);
var config = builder.Configuration;

// ── Serilog ────────────────────────────────────────────────────────────────
builder.SerilogConfig(config);

// ── Database ────────────────────────────────────────────────────────────────
builder.Services.AddDbContext<FluentFlowDbContext>(options =>
    options.UseSqlServer(config.GetConnectionString("Default"),
        sql => sql.MigrationsAssembly("FluentFlow.Infrastructure")));

// ── Identity ─────────────────────────────────────────────────────────────────
builder.Services.AddIdentity<ApplicationUser, IdentityRole<Guid>>(options =>
{
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = false;
    options.User.RequireUniqueEmail = true;
    options.SignIn.RequireConfirmedEmail = false; // activar em produção
})
.AddEntityFrameworkStores<FluentFlowDbContext>()
.AddDefaultTokenProviders();

// ── Authentication — JWT + Social ────────────────────────────────────────────
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme    = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer           = true,
        ValidateAudience         = true,
        ValidateLifetime         = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer              = config["Jwt:Issuer"],
        ValidAudience            = config["Jwt:Audience"],
        IssuerSigningKey         = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(config["Jwt:Key"]!)),
        ClockSkew = TimeSpan.Zero
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
    options.ClientId     = config["Auth:Google:ClientId"]!;
    options.ClientSecret = config["Auth:Google:ClientSecret"]!;
})
.AddGitHub(options =>
{
    options.ClientId     = config["Auth:GitHub:ClientId"]!;
    options.ClientSecret = config["Auth:GitHub:ClientSecret"]!;
});

builder.Services.AddAuthorization();

// ── Controllers + OpenAPI ────────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// ── CORS ─────────────────────────────────────────────────────────────────────
var allowedOrigins = builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? [];
var allowAllDev = builder.Configuration.GetValue<bool>("AllowAllOriginsDev");
builder.Services.AddCors(options =>
    options.AddPolicy("FluentFlowPolicy", policy =>
    {
        if (allowAllDev && builder.Environment.IsDevelopment())
        {
            // Desenvolvimento mobile — permite qualquer origin
            policy.SetIsOriginAllowed(_ => true)
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials();
        }
        else
        {
            policy.WithOrigins(allowedOrigins)
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials();
        }
    }));

// ── Application Services ─────────────────────────────────────────────────────
builder.Services.AddScoped<IDeckService, DeckService>();
builder.Services.AddScoped<ICardService, CardService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IStudySchedulerService, StudySchedulerService>();
builder.Services.AddScoped<IStudySessionService, StudySessionService>();
builder.Services.AddScoped<IAudioBatchService, AudioBatchService>();
builder.Services.AddScoped<ILogService, LogService>();

// ── FluentValidation ─────────────────────────────────────────────────────────
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<CreateDeckValidator>();

// ── Storage ───────────────────────────────────────────────────────────────────
builder.Services.AddScoped<IStorageService, LocalStorageService>();

// ── Speech-to-Text (Whisper.net — singleton: modelo carregado uma vez) ────────
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

// ── AudioBatchProcessor (Singleton: channel partilhado) ───────────────────────
builder.Services.AddSingleton<AudioBatchProcessor>();
builder.Services.AddHostedService(sp => sp.GetRequiredService<AudioBatchProcessor>());
builder.Services.AddScoped<IBatchProgressNotifier, SignalRBatchProgressNotifier>();
builder.Services.AddSingleton<AudioConverterService>();
builder.Services.AddSingleton<IAudioConverterService>(sp => sp.GetRequiredService<AudioConverterService>());
builder.Services.AddHostedService(sp => sp.GetRequiredService<AudioConverterService>());

// ── Auth Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();

var app = builder.Build();

// ── Serilog ────────────────────────────────────────────────────────────────
app.SerilogUse();

// ── Migrations automáticas ───────────────────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<FluentFlowDbContext>();
    await db.Database.MigrateAsync();
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options.Title = "FluentFlow API";
        options.Theme = ScalarTheme.DeepSpace;
    });
}

// Servir ficheiros de áudio do App_Data/Uploads
var uploadsPath = Path.Combine(builder.Environment.ContentRootPath, "App_Data", "Uploads");
Directory.CreateDirectory(uploadsPath);

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsPath),
    RequestPath  = "/uploads"
});

app.UseHttpsRedirection();
app.UseCors("FluentFlowPolicy");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// ── SignalR Hub ───────────────────────────────────────────────────────────────
app.MapHub<BatchProgressHub>("/hubs/batch");

app.Run();