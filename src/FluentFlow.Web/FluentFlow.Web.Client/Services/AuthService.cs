using FluentFlow.Core.DTOs.Auth;
using Microsoft.AspNetCore.Components;

namespace FluentFlow.Web.Client.Services;

public class WebAuthService(ApiClient api, TokenAuthStateProvider authStateProvider, NavigationManager nav)
{
    public async Task<(bool Success, string? Error)> LoginAsync(LoginDto dto)
    {
        var result = await api.LoginAsync(dto);
        if (!result.Success) return (false, "Email ou password incorrectos.");

        await authStateProvider.SetAuthAsync(result.Value!);
        return (true, null);
    }

    public async Task<(bool Success, string? Error)> RegisterAsync(RegisterDto dto)
    {
        var result = await api.RegisterAsync(dto);
        if (!result.Success) return (false, "Erro ao criar conta. Verifique os dados.");

        await authStateProvider.SetAuthAsync(result.Value!);
        return (true, null);
    }

    public async Task LogoutAsync()
    {
        var refreshToken = await authStateProvider.GetRefreshTokenAsync();
        if (refreshToken is not null)
            await api.LogoutAsync(new RefreshTokenDto(refreshToken));

        await authStateProvider.ClearAuthAsync();
        nav.NavigateTo("/login");
    }
    
    public async Task SetTokensAsync(string accessToken, string refreshToken)
    {
        // Construir o AuthResultDto a partir dos tokens recebidos
        // sem fazer round-trip à API
        var authResult = new AuthResultDto(
            AccessToken: accessToken,
            RefreshToken: refreshToken,
            ExpiresAt: DateTime.UtcNow.AddHours(1), // estimativa — o token tem a expiração real
            User: ParseUserFromToken(accessToken));

        await authStateProvider.SetAuthAsync(authResult);
    }
    
    private static UserInfoDto ParseUserFromToken(string accessToken)
    {
        try
        {
            // Decodificar o payload do JWT (parte central, base64url)
            var parts = accessToken.Split('.');
            if (parts.Length != 3) return DefaultUser();

            var payload = parts[1];

            // Padding base64url → base64 standard
            var padded = (payload.Length % 4) switch
            {
                2 => payload + "==",
                3 => payload + "=",
                _ => payload
            };
            padded = padded.Replace('-', '+').Replace('_', '/');

            var json = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(padded));
            var claims = System.Text.Json.JsonDocument.Parse(json).RootElement;

            return new UserInfoDto(
                Id: Guid.Parse(GetClaim(claims, "sub", Guid.NewGuid().ToString())),
                Name: GetClaim(claims, "name", "Utilizador"),
                Email: GetClaim(claims, "email", ""),
                UserType: GetClaim(claims, "userType", "Standard"),
                ProfileImageUrl: GetClaim(claims, "profileImage", null));
        }
        catch
        {
            return DefaultUser();
        }
    }

    private static string GetClaim(System.Text.Json.JsonElement element, string key, string? fallback)
    {
        if (element.TryGetProperty(key, out var val))
            return val.GetString() ?? fallback ?? "";
        return fallback ?? "";
    }

    private static UserInfoDto DefaultUser() => new(
        Id: Guid.NewGuid(),
        Name: "Utilizador",
        Email: "",
        UserType: "Standard",
        ProfileImageUrl: null);
}