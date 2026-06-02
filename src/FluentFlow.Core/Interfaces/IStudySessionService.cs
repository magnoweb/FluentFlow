using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface IStudySessionService
{
    Task<Result<Guid>> StartAsync(StartSessionDto dto, Guid userId);
    Task<Result> SubmitReviewAsync(SubmitReviewDto dto, Guid userId);
    Task<Result<SessionResultDto>> EndAsync(Guid sessionId, Guid userId);
    Task<Result<DashboardDto>> GetDashboardAsync(Guid deckId, Guid userId);
    Task<PagedResult<StudySessionListDto>> GetSessionsAsync(Guid userId, Guid? deckId, string? mode, int page, int pageSize);
    Task<Result<StudySessionDetailDto>> GetSessionDetailAsync(Guid sessionId, Guid userId);
}