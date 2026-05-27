using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Interfaces;

public interface IStudySchedulerService
{
    Task<Result<StudyPlanDto>> GetPlanAsync(Guid deckId, Guid userId, StudyMode mode);
}