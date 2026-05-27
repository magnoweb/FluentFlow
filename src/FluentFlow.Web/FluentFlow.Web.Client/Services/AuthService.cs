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
}