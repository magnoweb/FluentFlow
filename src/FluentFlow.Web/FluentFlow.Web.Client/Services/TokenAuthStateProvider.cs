using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using FluentFlow.Core.DTOs.Auth;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;

namespace FluentFlow.Web.Client.Services;

public class TokenAuthStateProvider(IJSRuntime js) : AuthenticationStateProvider
{
    private const string AccessTokenKey  = "ff_access_token";
    private const string RefreshTokenKey = "ff_refresh_token";

    private static readonly AuthenticationState Anonymous = new(new ClaimsPrincipal(new ClaimsIdentity()));

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        // Durante SSR o JS interop não está disponível — retornar anónimo
        if (IsPrerendering())
            return Anonymous;

        try
        {
            var token = await GetAccessTokenAsync();
            if (string.IsNullOrEmpty(token))
                return Anonymous;

            var claims = ParseClaimsFromJwt(token);
            var identity = new ClaimsIdentity(claims, "jwt");
            return new AuthenticationState(new ClaimsPrincipal(identity));
        }
        catch
        {
            return Anonymous;
        }
    }

    public async Task SetAuthAsync(AuthResultDto auth)
    {
        if (IsPrerendering()) return;

        await js.InvokeVoidAsync("localStorage.setItem", AccessTokenKey,  auth.AccessToken);
        await js.InvokeVoidAsync("localStorage.setItem", RefreshTokenKey, auth.RefreshToken);
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
    }

    public async Task ClearAuthAsync()
    {
        if (IsPrerendering()) return;

        await js.InvokeVoidAsync("localStorage.removeItem", AccessTokenKey);
        await js.InvokeVoidAsync("localStorage.removeItem", RefreshTokenKey);
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
    }

    public async Task<string?> GetAccessTokenAsync()
    {
        if (IsPrerendering()) return null;
        try
        {
            return await js.InvokeAsync<string?>("localStorage.getItem", AccessTokenKey);
        }
        catch { return null; }
    }

    public async Task<string?> GetRefreshTokenAsync()
    {
        if (IsPrerendering()) return null;
        try
        {
            return await js.InvokeAsync<string?>("localStorage.getItem", RefreshTokenKey);
        }
        catch { return null; }
    }
    
    public async Task<string?> GetUserTypeAsync()
    {
        var token = await GetAccessTokenAsync();
        if (string.IsNullOrEmpty(token)) return null;
        return ParseClaimsFromJwt(token).FirstOrDefault(c => c.Type == "userType")?.Value;
    }

    public async Task<string?> GetProfileImageAsync()
    {
        var token = await GetAccessTokenAsync();
        if (string.IsNullOrEmpty(token)) return null;
        var val = ParseClaimsFromJwt(token).FirstOrDefault(c => c.Type == "profileImage")?.Value;
        return string.IsNullOrEmpty(val) ? null : val;
    }
    
    // Detecta se estamos em prerendering (servidor) vs browser
    // IJSRuntime no servidor é RemoteJSRuntime; no browser é WebAssemblyJSRuntime
    private bool IsPrerendering() =>
        js.GetType().Name.Contains("Unsupported", StringComparison.OrdinalIgnoreCase) ||
        js.GetType().Name.Contains("Remote",      StringComparison.OrdinalIgnoreCase);

    private static IEnumerable<Claim> ParseClaimsFromJwt(string jwt)
    {
        var handler = new JwtSecurityTokenHandler();
        var token   = handler.ReadJwtToken(jwt);
        return token.Claims;
    }
}