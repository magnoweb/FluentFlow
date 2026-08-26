using System.Net.Http.Json;
using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs.Auth;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Enums;

namespace FluentFlow.Web.Client.Services;

public class ApiClient(HttpClient http)
{
    public string ApiBaseUrl => http.BaseAddress?.ToString();
    
    // ── Auth ──────────────────────────────────────────────────────────────────
    public Task<ApiResult<AuthResultDto>> RegisterAsync(RegisterDto dto) =>
        PostAsync<AuthResultDto>("api/auth/register", dto);

    public Task<ApiResult<AuthResultDto>> LoginAsync(LoginDto dto) =>
        PostAsync<AuthResultDto>("api/auth/login", dto);

    public Task<ApiResult<AuthResultDto>> RefreshAsync(RefreshTokenDto dto) => PostAsync<AuthResultDto>("api/auth/refresh", dto);

    public Task<ApiResult> LogoutAsync(RefreshTokenDto dto) =>
        PostVoidAsync("api/auth/logout", dto);

    // ── Profile ───────────────────────────────────────────────────────────────────
    public Task<ApiResult<UserProfileDto>> GetProfileAsync() => GetAsync<UserProfileDto>("api/auth/profile");

    public Task<ApiResult<UserProfileDto>> UpdateProfileAsync(UpdateProfileDto dto) => PutAsync<UserProfileDto>("api/auth/profile", dto);
    
    // ── Decks ─────────────────────────────────────────────────────────────────
    public Task<PagedResult<DeckDto>?> GetDecksAsync(int page = 1, int pageSize = 20) =>
        http.GetFromJsonAsync<PagedResult<DeckDto>>($"api/decks?page={page}&pageSize={pageSize}");

    public Task<DeckDto?> GetDeckAsync(Guid id) =>
        http.GetFromJsonAsync<DeckDto>($"api/decks/{id}");

    public Task<ApiResult<DeckDto>> CreateDeckAsync(CreateDeckDto dto) =>
        PostAsync<DeckDto>("api/decks", dto);

    public Task<ApiResult<DeckDto>> UpdateDeckAsync(Guid id, UpdateDeckDto dto) =>
        PutAsync<DeckDto>($"api/decks/{id}", dto);

    public Task<ApiResult> DeleteDeckAsync(Guid id) =>
        DeleteAsync($"api/decks/{id}");

    // ── Cards ─────────────────────────────────────────────────────────────────
    public Task<PagedResult<CardDto>?> GetCardsAsync(Guid deckId, int page = 1, int pageSize = 20, string? search = null)
    {
        var url = $"api/decks/{deckId}/cards?page={page}&pageSize={pageSize}";
        if (!string.IsNullOrWhiteSpace(search))
            url += $"&search={Uri.EscapeDataString(search)}";
        return http.GetFromJsonAsync<PagedResult<CardDto>>(url);
    }

    public Task<ApiResult<CardDto>> CreateCardAsync(Guid deckId, CreateCardDto dto) =>
        PostAsync<CardDto>($"api/decks/{deckId}/cards", dto);

    public Task<ApiResult<CardDto>> UpdateCardAsync(Guid deckId, Guid cardId, UpdateCardDto dto) =>
        PutAsync<CardDto>($"api/decks/{deckId}/cards/{cardId}", dto);

    public Task<ApiResult> DeleteCardAsync(Guid deckId, Guid cardId) =>
        DeleteAsync($"api/decks/{deckId}/cards/{cardId}");
    
    // ── Card Audio ────────────────────────────────────────────────────────────────
    public async Task<ApiResult<CardAudioDto>> UploadCardAudioAsync(Guid deckId, Guid cardId, UploadFileDto file)
    {
        try
        {
            using var content  = new MultipartFormDataContent();
            using var byteContent = new ByteArrayContent(file.Bytes);
            
            byteContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType);
            content.Add(byteContent, "file", file.FileName);

            var response = await http.PostAsync($"api/decks/{deckId}/cards/{cardId}/audio", content);
            return await ParseAsync<CardAudioDto>(response);
        }
        catch (Exception ex)
        {
            return ApiResult<CardAudioDto>.Fail($"Erro de ligação: {ex.Message}");
        }
    }

    public async Task<ApiResult> DeleteCardAudioAsync(Guid deckId, Guid cardId)
    {
        try
        {
            var response = await http.DeleteAsync($"api/decks/{deckId}/cards/{cardId}/audio");
            return response.IsSuccessStatusCode
                ? ApiResult.Ok()
                : ApiResult.Fail(await ReadErrorAsync(response));
        }
        catch (Exception ex)
        {
            return ApiResult.Fail($"Erro de ligação: {ex.Message}");
        }
    }
    
    // ── Batch ─────────────────────────────────────────────────────────────────────
    public async Task<ApiResult<Guid>> UploadBatchAsync(Guid deckId, MultipartFormDataContent content)
    {
        try
        {
            var response = await http.PostAsync($"api/batch/upload/{deckId}", content);
            if (!response.IsSuccessStatusCode)
            {
                var err = await ReadErrorAsync(response);
                return ApiResult<Guid>.Fail(err);
            }
            var result = await response.Content.ReadFromJsonAsync<UploadBatchResponse>();
            return ApiResult<Guid>.Ok(result!.JobId);
        }
        catch (Exception ex)
        {
            return ApiResult<Guid>.Fail($"Erro de ligação: {ex.Message}");
        }
    }

    public Task<BatchJobDto?> GetJobAsync(Guid jobId) =>
        http.GetFromJsonAsync<BatchJobDto>($"api/batch/jobs/{jobId}/status");

    private record UploadBatchResponse(Guid JobId);

    // ── Study ─────────────────────────────────────────────────────────────────
    public Task<StudyPlanDto?> GetPlanAsync(Guid deckId, StudyMode mode) =>
        http.GetFromJsonAsync<StudyPlanDto>($"api/study/plan/{deckId}?mode={mode}");

    public Task<DashboardDto?> GetDashboardAsync(Guid deckId) =>
        http.GetFromJsonAsync<DashboardDto>($"api/study/dashboard/{deckId}");

    public async Task<ApiResult<Guid>> StartSessionAsync(StartSessionDto dto)
    {
        var result = await PostAsync<StartSessionResponse>("api/study/start", dto);
        if (!result.Success) return ApiResult<Guid>.Fail(result.Error);
        return ApiResult<Guid>.Ok(result.Value!.SessionId);
    }
    
    public string GetAudioUrl(string path) => path.StartsWith("http") ? path : $"{http.BaseAddress}uploads/{path}";

    public Task<ApiResult> SubmitReviewAsync(SubmitReviewDto dto) => PostVoidAsync("api/study/review", dto);

    public Task<ApiResult<SessionResultDto>> EndSessionAsync(Guid sessionId) =>
        PostAsync<SessionResultDto>($"api/study/end/{sessionId}", new { });

    public Task<PagedResult<StudySessionListDto>?> GetSessionsAsync(int page = 1, int pageSize = 20, string? modeFilter = null)
    {
        var qs = $"api/study/sessions?page={page}&pageSize={pageSize}";
        if (modeFilter is not null) qs += $"&mode={modeFilter}";
        return http.GetFromJsonAsync<PagedResult<StudySessionListDto>>(qs);
    }

    public Task<StudySessionDetailDto?> GetSessionDetailAsync(Guid id) =>
        http.GetFromJsonAsync<StudySessionDetailDto>($"api/study/sessions/{id}");
    
    // ── Transcrição (Speaking mode) ───────────────────────────────────────────────
    public async Task<ApiResult<TranscribeResultDto>> TranscribeAudioAsync(string audioBase64, string extension, string originalText, Guid deckId)
    {
        // Buscar idioma do deck
        var deck = await GetDeckAsync(deckId);
        if (deck is null)
            return ApiResult<TranscribeResultDto>.Fail("Deck não encontrado.");

        return await PostAsync<TranscribeResultDto>("api/study/transcribe", new TranscribeRequestDto(audioBase64, extension, originalText, deck.Language));
    }

    // ── Logs ──────────────────────────────────────────────────────────────────────
    public Task<PagedResult<LogDto>?> GetLogsAsync(LogFilterDto filter)
    {
        var qs = $"api/logs?page={filter.Page}&pageSize={filter.PageSize}";
        if (!string.IsNullOrEmpty(filter.Level))   qs += $"&level={filter.Level}";
        if (!string.IsNullOrEmpty(filter.Search))  qs += $"&search={Uri.EscapeDataString(filter.Search)}";
        if (filter.DateFrom.HasValue) qs += $"&dateFrom={filter.DateFrom:yyyy-MM-dd}";
        if (filter.DateTo.HasValue)   qs += $"&dateTo={filter.DateTo:yyyy-MM-dd}";
        return http.GetFromJsonAsync<PagedResult<LogDto>>(qs);
    }

    public Task<LogDetailDto?> GetLogAsync(int id) => http.GetFromJsonAsync<LogDetailDto>($"api/logs/{id}");
    
    // ── Admin ─────────────────────────────────────────────────────────────────────
    public Task<PagedResult<AdminUserListDto>?> GetAdminUsersAsync(int page = 1, int pageSize = 20, string? search = null)
    {
        var qs = $"api/admin/users?page={page}&pageSize={pageSize}";
        if (!string.IsNullOrEmpty(search)) qs += $"&search={Uri.EscapeDataString(search)}";
        return http.GetFromJsonAsync<PagedResult<AdminUserListDto>>(qs);
    }

    public Task<AdminUserDetailDto?> GetAdminUserDetailAsync(Guid id) =>
        http.GetFromJsonAsync<AdminUserDetailDto>($"api/admin/users/{id}");

    public Task<PagedResult<AccessLogDto>?> GetAccessLogsAsync(AccessLogFilterDto filter)
    {
        var qs = $"api/admin/access-logs?page={filter.Page}&pageSize={filter.PageSize}";
        if (filter.UserId.HasValue)    qs += $"&userId={filter.UserId}";
        if (!string.IsNullOrEmpty(filter.Platform)) qs += $"&platform={filter.Platform}";
        if (filter.DateFrom.HasValue)  qs += $"&dateFrom={filter.DateFrom:yyyy-MM-dd}";
        if (filter.DateTo.HasValue)    qs += $"&dateTo={filter.DateTo:yyyy-MM-dd}";
        return http.GetFromJsonAsync<PagedResult<AccessLogDto>>(qs);
    }
    
    // ── Core HTTP helpers ─────────────────────────────────────────────────────
    private async Task<ApiResult<T>> GetAsync<T>(string url)
    {
        try
        {
            var response = await http.GetAsync(url);
            return await ParseAsync<T>(response);
        }
        catch (Exception ex)
        {
            return ApiResult<T>.Fail($"Erro de ligação: {ex.Message}");
        }
    }
    private async Task<ApiResult<T>> PostAsync<T>(string url, object body)
    {
        try
        {
            var response = await http.PostAsJsonAsync(url, body);
            return await ParseAsync<T>(response);
        }
        catch (Exception ex)
        {
            return ApiResult<T>.Fail($"Erro de ligação: {ex.Message}");
        }
    }

    private async Task<ApiResult<T>> PutAsync<T>(string url, object body)
    {
        try
        {
            var response = await http.PutAsJsonAsync(url, body);
            return await ParseAsync<T>(response);
        }
        catch (Exception ex)
        {
            return ApiResult<T>.Fail($"Erro de ligação: {ex.Message}");
        }
    }

    private async Task<ApiResult> PostVoidAsync(string url, object body)
    {
        try
        {
            var response = await http.PostAsJsonAsync(url, body);
            if (response.IsSuccessStatusCode) return ApiResult.Ok();
            var err = await ReadErrorAsync(response);
            return ApiResult.Fail(err);
        }
        catch (Exception ex)
        {
            return ApiResult.Fail($"Erro de ligação: {ex.Message}");
        }
    }

    private async Task<ApiResult> DeleteAsync(string url)
    {
        try
        {
            var response = await http.DeleteAsync(url);
            if (response.IsSuccessStatusCode) return ApiResult.Ok();
            var err = await ReadErrorAsync(response);
            return ApiResult.Fail(err);
        }
        catch (Exception ex)
        {
            return ApiResult.Fail($"Erro de ligação: {ex.Message}");
        }
    }

    private static async Task<ApiResult<T>> ParseAsync<T>(HttpResponseMessage response)
    {
        if (response.IsSuccessStatusCode)
        {
            var value = await response.Content.ReadFromJsonAsync<T>();
            return ApiResult<T>.Ok(value!);
        }
        var error = await ReadErrorAsync(response);
        return ApiResult<T>.Fail(error);
    }

    // Lê a mensagem de erro da API (campo "error" ou texto raw)
    private static async Task<string> ReadErrorAsync(HttpResponseMessage response)
    {
        try
        {
            var body = await response.Content.ReadFromJsonAsync<ApiErrorResponse>();
            return body?.Error
                ?? $"Erro {(int)response.StatusCode}: {response.ReasonPhrase}";
        }
        catch
        {
            return $"Erro {(int)response.StatusCode}: {response.ReasonPhrase}";
        }
    }

    private record ApiErrorResponse(string? Error);
    private record StartSessionResponse(Guid SessionId);
}