using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface ILogService
{
    Task<PagedResult<LogDto>> GetPagedAsync(LogFilterDto filter);
    Task<LogDetailDto?> GetByIdAsync(int id);
}