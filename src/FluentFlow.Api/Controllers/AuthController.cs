using FluentFlow.Api.Extensions;
using FluentFlow.Core.DTOs.Auth;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService authService) : ControllerBase
{
    private string IpAddress => HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var result = await authService.RegisterAsync(dto, IpAddress);
        if (!result.IsSuccess) return BadRequest(new { error = result.Error });
        return Ok(result.Value);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var result = await authService.LoginAsync(dto, IpAddress);
        if (!result.IsSuccess) return Unauthorized(new { error = result.Error });
        return Ok(result.Value);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenDto dto)
    {
        var result = await authService.RefreshAsync(dto.RefreshToken, IpAddress);
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
    // Redireciona para o provider (Google/GitHub)
    [HttpGet("login/{provider}")]
    public IActionResult SocialLogin(string provider, [FromQuery] string returnUrl = "/")
    {
        var redirectUrl = Url.Action(nameof(SocialCallback), "Auth", new { provider, returnUrl });
        var properties = new AuthenticationProperties { RedirectUri = redirectUrl };

        return Challenge(properties, provider);
    }

    // Callback após autenticação social — emite JWT e redireciona
    [HttpGet("callback/{provider}")]
    public async Task<IActionResult> SocialCallback(string provider, string returnUrl = "/")
    {
        var authenticateResult = await HttpContext.AuthenticateAsync(provider);

        if (!authenticateResult.Succeeded)
            return BadRequest(new { error = "Falha na autenticação social." });

        var claims = authenticateResult.Principal!.Claims.ToList();

        var providerUserId = claims
            .FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
            ?? throw new InvalidOperationException("ProviderUserId não encontrado.");

        var email = claims
            .FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Email)?.Value
            ?? throw new InvalidOperationException("Email não encontrado no provider.");

        var name = claims
            .FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Name)?.Value
            ?? email;

        var result = await authService.SocialLoginAsync(
            provider, providerUserId, email, name, IpAddress);

        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });

        // Para SPA/mobile: redirecionar com token na query string
        // Em produção use fragmento (#) ou cookie HttpOnly
        var redirectTarget =
            $"{returnUrl}?accessToken={result.Value!.AccessToken}" +
            $"&refreshToken={result.Value.RefreshToken}";

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
            return BadRequest(new { error = "Imagem demasiado grande. Máximo 200 KB." });
        
        var result = await authService.UpdateProfileAsync(User.GetUserId(), dto);
        return result.IsSuccess ? Ok(result.Value) : BadRequest(new { error = result.Error });
    }

    #endregion
}