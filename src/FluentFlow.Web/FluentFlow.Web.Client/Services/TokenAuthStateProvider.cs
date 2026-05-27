using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using FluentFlow.Core.DTOs.Auth;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;

namespace FluentFlow.Web.Services;

public class TokenAuthStateProvider(IJSRuntime js) : AuthenticationStateProvider
{
    private const string AccessTokenKey  = "ff_access_token";
    private const string RefreshTokenKey = "ff_refresh_token";

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        var token = await GetAccessTokenAsync();
        if (string.IsNullOrEmpty(token))
            return new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity()));

        var claims  = ParseClaimsFromJwt(token);
        var identity = new ClaimsIdentity(claims, "jwt");
        return new AuthenticationState(new ClaimsPrincipal(identity));
    }

    public async Task SetAuthAsync(AuthResultDto auth)
    {
        await js.InvokeVoidAsync("localStorage.setItem", AccessTokenKey,  auth.AccessToken);
        await js.InvokeVoidAsync("localStorage.setItem", RefreshTokenKey, auth.RefreshToken);
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
    }

    public async Task ClearAuthAsync()
    {
        await js.InvokeVoidAsync("localStorage.removeItem", AccessTokenKey);
        await js.InvokeVoidAsync("localStorage.removeItem", RefreshTokenKey);
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
    }

    public async Task<string?> GetAccessTokenAsync() =>
        await js.InvokeAsync<string?>("localStorage.getItem", AccessTokenKey);

    public async Task<string?> GetRefreshTokenAsync() =>
        await js.InvokeAsync<string?>("localStorage.getItem", RefreshTokenKey);

    private static IEnumerable<Claim> ParseClaimsFromJwt(string jwt)
    {
        var handler = new JwtSecurityTokenHandler();
        var token   = handler.ReadJwtToken(jwt);
        return token.Claims;
    }
}