using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface IStudySessionService
{
    Task<Result<Guid>> StartAsync(StartSessionDto dto, Guid userId);
    Task<Result> SubmitReviewAsync(SubmitReviewDto dto, Guid userId);
    Task<Result<SessionResultDto>> EndAsync(Guid sessionId, Guid userId);
    Task<Result<DashboardDto>> GetDashboardAsync(Guid deckId, Guid userId);
}