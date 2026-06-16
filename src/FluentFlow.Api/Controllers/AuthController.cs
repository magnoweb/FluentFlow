using FluentFlow.Api.Extensions;
using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs.Auth;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService authService, IConfiguration config) : ControllerBase
{
    private string IpAddress => HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    private string Platform
    {
        get
        {
            // Cliente Flutter envia header próprio
            if (Request.Headers.TryGetValue("X-Client-Platform", out var custom) &&
                !string.IsNullOrWhiteSpace(custom))
                return custom.ToString();

            var ua = Request.Headers.UserAgent.ToString();
            if (string.IsNullOrEmpty(ua)) return "Unknown";

            if (ua.Contains("Dart") || ua.Contains("okhttp") || ua.Contains("CFNetwork"))
                return "Mobile";

            return "Web";
        }
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var result = await authService.RegisterAsync(dto, IpAddress, Platform);
        if (!result.IsSuccess) return BadRequest(new { error = result.Error });
        return Ok(result.Value);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var result = await authService.LoginAsync(dto, IpAddress, Platform);
        if (!result.IsSuccess) return Unauthorized(new { error = result.Error });
        return Ok(result.Value);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenDto dto)
    {
        var result = await authService.RefreshAsync(dto.RefreshToken, IpAddress, Platform);
        if (!result.IsSuccess) return Unauthorized(new { error = result.Error });
        return Ok(result.Value);
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] RefreshTokenDto dto)
    {
        var result = await authService.RevokeAsync(dto.RefreshToken);
        if (!result.IsSuccess) return BadRequest(new { error = result.Error });
        return NoContent();
    }

    // ── Social Login ──────────────────────────────────────────────────────────
    // Redireciona para o provider (Google/Microsoft/GitHub)
    [HttpGet("login/{provider}")]
    public IActionResult SocialLogin(string provider, [FromQuery] string? returnUrl = null)
    {
        var redirectUrl = Url.Action(nameof(SocialCallback), "Auth", new { provider, returnUrl }, protocol: "https");
        var properties = new AuthenticationProperties { RedirectUri = redirectUrl };

        return Challenge(properties, provider);
    }

    // Callback após autenticação social — emite JWT e redireciona
    [HttpGet("callback/{provider}")]
    public async Task<IActionResult> SocialCallback(string provider, [FromQuery] string? returnUrl = null)
    {
        var authenticateResult = await HttpContext.AuthenticateAsync(provider);

        if (!authenticateResult.Succeeded || authenticateResult.Principal is null)
            return BadRequest(new { error = LocalizationHelper.Get("Api.SocialAuthFailed") });

        var claims = authenticateResult.Principal!.Claims.ToList();

        var providerUserId = claims
            .FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

        var email = claims
            .FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Email)?.Value;
        
        if (string.IsNullOrEmpty(providerUserId) || string.IsNullOrEmpty(email))
        {
            return Redirect(BuildCallbackUrl(returnUrl, error: LocalizationHelper.Get("Api.MissingProviderData")));
        }

        var name = claims
            .FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Name)?.Value
            ?? email;

        var result = await authService.SocialLoginAsync(provider, providerUserId, email, name, IpAddress, Platform);

        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });

        // Para SPA/mobile: redirecionar com token na query string
        // Em produção use fragmento (#) ou cookie HttpOnly
        // var redirectTarget = $"{returnUrl}?accessToken={result.Value!.AccessToken}&refreshToken={result.Value.RefreshToken}";
        var redirectTarget = BuildCallbackUrl(returnUrl, accessToken: result.Value!.AccessToken, refreshToken: result.Value.RefreshToken);

        return Redirect(redirectTarget);
    }

    #region Profile

    [Authorize]
    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile() => (await authService.GetProfileAsync(User.GetUserId())).ToActionResult();
    
    [Authorize]
    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
    {
        // Validar tamanho do avatar — base64 de 200KB ≈ 267KB em texto
        if (dto.ProfileImageBase64 is { Length: > 280_000 })
            return BadRequest(new { error = LocalizationHelper.Get("Api.FileTooLarge") });
        
        var result = await authService.UpdateProfileAsync(User.GetUserId(), dto);
        return result.IsSuccess ? Ok(result.Value) : BadRequest(new { error = result.Error });
    }

    #endregion
    
    // ── Helper ────────────────────────────────────────────────────────────────────
    private string BuildCallbackUrl(string? returnUrl, string? accessToken = null, string? refreshToken = null, string? error = null)
    {
        // returnUrl pode ser um deep link do mobile (ex.: fluentflow://auth/social-callback)
        // ou uma URL web (ex.: https://fluentflow.magnoweb.net)
        if (!string.IsNullOrWhiteSpace(returnUrl) && Uri.TryCreate(returnUrl, UriKind.Absolute, out var callbackUri))
        {
            if (callbackUri.Scheme.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            {
                var baseUrl = callbackUri.GetLeftPart(UriPartial.Authority) + callbackUri.AbsolutePath.TrimEnd('/');
                if (!baseUrl.EndsWith("/social-callback", StringComparison.OrdinalIgnoreCase))
                    baseUrl += "/social-callback";

                return AppendQueryString(baseUrl, accessToken, refreshToken, error);
            }

            return AppendQueryString(callbackUri.ToString(), accessToken, refreshToken, error);
        }

        var fallbackBaseUrl = config["AppBaseUrl"] ?? "https://fluentflow.magnoweb.net";
        return AppendQueryString(fallbackBaseUrl.TrimEnd('/') + "/social-callback", accessToken, refreshToken, error);
    }

    private static string AppendQueryString(string baseUrl, string? accessToken, string? refreshToken, string? error)
    {
        var query = new List<string>();

        if (!string.IsNullOrWhiteSpace(error))
            query.Add($"error={Uri.EscapeDataString(error)}");

        if (!string.IsNullOrWhiteSpace(accessToken))
            query.Add($"accessToken={Uri.EscapeDataString(accessToken)}");

        if (!string.IsNullOrWhiteSpace(refreshToken))
            query.Add($"refreshToken={Uri.EscapeDataString(refreshToken)}");

        return query.Count == 0 ? baseUrl : $"{baseUrl}?{string.Join("&", query)}";
    }
}