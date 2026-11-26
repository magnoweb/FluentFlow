using System.Net.Http.Json;
using Microsoft.AspNetCore.Components;

namespace FluentFlow.Web.Client.Services;

public class AuthorizationMessageHandler(
    TokenAuthStateProvider authStateProvider,
    NavigationManager nav) : DelegatingHandler
{
    // ── Single-flight refresh ────────────────────────────────────────────────
    // O backend usa refresh tokens de USO ÚNICO (rotação — AuthService.RefreshAsync
    // revoga o token antigo assim que é usado). O Blazor WASM pode ter vários pedidos
    // HTTP em curso ao mesmo tempo (ex.: sessão de estudo com várias chamadas em
    // paralelo); se o access token expira, CADA pedido que apanha 401 disparava o seu
    // próprio refresh, todos com o MESMO refresh token antigo. O primeiro a chegar ao
    // backend tinha sucesso e revogava o token; os restantes, com o mesmo token já
    // revogado, falhavam e provocavam um logout/redirect para /login a meio de uma
    // sessão activa — mesmo esta continuando válida (o 1º refresh tinha corrido bem).
    //
    // Para evitar isto: só um refresh é disparado de cada vez (semáforo); qualquer
    // pedido concorrente aguarda por esse MESMO refresh em vez de iniciar o seu, e se
    // entretanto detectar que o token já mudou (outro pedido já renovou), nem chega a
    // chamar o endpoint de refresh — só reenvia o pedido original com o token novo.
    private static readonly SemaphoreSlim RefreshLock = new(1, 1);
    private static Task<bool>? _refreshInFlight;

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
            var tokenAtFailure = token;
            var currentToken = await authStateProvider.GetAccessTokenAsync();

            // Outro pedido concorrente já renovou o token entretanto — não repetir o refresh
            var refreshed = !string.IsNullOrEmpty(currentToken) && currentToken != tokenAtFailure
                ? true
                : await GetOrStartRefreshAsync();

            if (refreshed)
            {
                token = await authStateProvider.GetAccessTokenAsync();
                request.Headers.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
                response.Dispose();
                response = await base.SendAsync(request, cancellationToken);
            }
            else
            {
                nav.NavigateTo("/login");
            }
        }

        return response;
    }

    private async Task<bool> GetOrStartRefreshAsync()
    {
        await RefreshLock.WaitAsync();
        try
        {
            // Já há um refresh em curso disparado por outro pedido concorrente — aguardar por ele
            if (_refreshInFlight is { IsCompleted: false })
                return await _refreshInFlight;

            _refreshInFlight = TryRefreshAsync();
            return await _refreshInFlight;
        }
        finally
        {
            RefreshLock.Release();
        }
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