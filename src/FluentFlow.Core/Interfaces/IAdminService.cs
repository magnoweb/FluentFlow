using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface IAdminService
{
    Task<PagedResult<AdminUserListDto>> GetUsersAsync(int page, int pageSize, string? search);
    Task<Result<AdminUserDetailDto>> GetUserDetailAsync(Guid userId);
    Task<PagedResult<AccessLogDto>> GetAccessLogsAsync(AccessLogFilterDto filter);
}