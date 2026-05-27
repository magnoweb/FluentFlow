using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.DTOs.Auth;
using FluentFlow.Core.Enums;

namespace FluentFlow.Web.Services;

public class ApiClient(HttpClient http)
{
    // ── Auth ──────────────────────────────────────────────────────────────────
    public Task<AuthResultDto?> RegisterAsync(RegisterDto dto) =>
        http.PostAsJsonAsync("api/auth/register", dto)
            .ContinueWith(t => t.Result.IsSuccessStatusCode
                ? t.Result.Content.ReadFromJsonAsync<AuthResultDto>().Result
                : null);

    public Task<AuthResultDto?> LoginAsync(LoginDto dto) =>
        PostAsync<AuthResultDto>("api/auth/login", dto);

    public Task<AuthResultDto?> RefreshAsync(RefreshTokenDto dto) =>
        PostAsync<AuthResultDto>("api/auth/refresh", dto);

    public Task LogoutAsync(RefreshTokenDto dto) =>
        http.PostAsJsonAsync("api/auth/logout", dto)
            .ContinueWith(_ => Task.CompletedTask);

    // ── Decks ─────────────────────────────────────────────────────────────────
    public Task<PagedResult<DeckDto>?> GetDecksAsync(int page = 1, int pageSize = 20) =>
        http.GetFromJsonAsync<PagedResult<DeckDto>>(
            $"api/decks?page={page}&pageSize={pageSize}");

    public Task<DeckDto?> GetDeckAsync(Guid id) =>
        http.GetFromJsonAsync<DeckDto>($"api/decks/{id}");

    public Task<DeckDto?> CreateDeckAsync(CreateDeckDto dto) =>
        PostAsync<DeckDto>("api/decks", dto);

    public Task<DeckDto?> UpdateDeckAsync(Guid id, UpdateDeckDto dto) =>
        PutAsync<DeckDto>($"api/decks/{id}", dto);

    public Task DeleteDeckAsync(Guid id) =>
        http.DeleteAsync($"api/decks/{id}");

    // ── Cards ─────────────────────────────────────────────────────────────────
    public Task<PagedResult<CardDto>?> GetCardsAsync(Guid deckId, int page = 1, int pageSize = 50) =>
        http.GetFromJsonAsync<PagedResult<CardDto>>(
            $"api/decks/{deckId}/cards?page={page}&pageSize={pageSize}");

    public Task<CardDto?> CreateCardAsync(Guid deckId, CreateCardDto dto) =>
        PostAsync<CardDto>($"api/decks/{deckId}/cards", dto);

    public Task<CardDto?> UpdateCardAsync(Guid deckId, Guid cardId, UpdateCardDto dto) =>
        PutAsync<CardDto>($"api/decks/{deckId}/cards/{cardId}", dto);

    public Task DeleteCardAsync(Guid deckId, Guid cardId) =>
        http.DeleteAsync($"api/decks/{deckId}/cards/{cardId}");

    // ── Study ─────────────────────────────────────────────────────────────────
    public Task<StudyPlanDto?> GetPlanAsync(Guid deckId, StudyMode mode) =>
        http.GetFromJsonAsync<StudyPlanDto>($"api/study/plan/{deckId}?mode={mode}");

    public Task<DashboardDto?> GetDashboardAsync(Guid deckId) =>
        http.GetFromJsonAsync<DashboardDto>($"api/study/dashboard/{deckId}");

    public async Task<Guid?> StartSessionAsync(StartSessionDto dto)
    {
        var response = await http.PostAsJsonAsync("api/study/start", dto);
        if (!response.IsSuccessStatusCode) return null;
        var result = await response.Content.ReadFromJsonAsync<StartSessionResponse>();
        return result?.SessionId;
    }

    public Task SubmitReviewAsync(SubmitReviewDto dto) =>
        http.PostAsJsonAsync("api/study/review", dto);

    public Task<SessionResultDto?> EndSessionAsync(Guid sessionId) =>
        PostAsync<SessionResultDto>($"api/study/end/{sessionId}", new { });

    // ── Helpers ───────────────────────────────────────────────────────────────
    private async Task<T?> PostAsync<T>(string url, object body)
    {
        var response = await http.PostAsJsonAsync(url, body);
        if (!response.IsSuccessStatusCode) return default;
        return await response.Content.ReadFromJsonAsync<T>();
    }

    private async Task<T?> PutAsync<T>(string url, object body)
    {
        var response = await http.PutAsJsonAsync(url, body);
        if (!response.IsSuccessStatusCode) return default;
        return await response.Content.ReadFromJsonAsync<T>();
    }

    private record StartSessionResponse(Guid SessionId);
}