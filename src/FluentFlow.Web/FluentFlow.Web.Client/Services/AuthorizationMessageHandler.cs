using Microsoft.AspNetCore.Components;

namespace FluentFlow.Web.Services;

public class AuthorizationMessageHandler(
    TokenAuthStateProvider authStateProvider,
    NavigationManager nav) : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await authStateProvider.GetAccessTokenAsync();

        if (!string.IsNullOrEmpty(token))
            request.Headers.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

        var response = await base.SendAsync(request, cancellationToken);

        // Token expirado — tentar refresh
        if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
        {
            var refreshed = await TryRefreshAsync();
            if (refreshed)
            {
                token = await authStateProvider.GetAccessTokenAsync();
                request.Headers.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
                response = await base.SendAsync(request, cancellationToken);
            }
            else
            {
                nav.NavigateTo("/login");
            }
        }

        return response;
    }

    private async Task<bool> TryRefreshAsync()
    {
        var refreshToken = await authStateProvider.GetRefreshTokenAsync();
        if (refreshToken is null) return false;

        // Criar HttpClient sem o handler para evitar loop
        using var client = new HttpClient { BaseAddress = new Uri(nav.BaseUri) };
        var result = await client.PostAsJsonAsync("api/auth/refresh",
            new { refreshToken });

        if (!result.IsSuccessStatusCode) return false;

        var auth = await result.Content
            .ReadFromJsonAsync<FluentFlow.Core.DTOs.Auth.AuthResultDto>();
        if (auth is null) return false;

        await authStateProvider.SetAuthAsync(auth);
        return true;
    }
}