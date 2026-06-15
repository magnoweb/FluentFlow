using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class AdminService(FluentFlowDbContext db) : IAdminService
{
    public async Task<PagedResult<AdminUserListDto>> GetUsersAsync(
        int page, int pageSize, string? search)
    {
        var query = db.Users.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(u =>
                u.Name.Contains(search) ||
                u.Email!.Contains(search));

        var total = await query.CountAsync();

        var items = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(u => new AdminUserListDto(
                u.Id,
                u.Name,
                u.Email!,
                u.UserType.ToString(),
                u.IsEnabled,
                u.CreatedAt,
                u.Decks.Count(d => d.IsActive),
                u.Decks.SelectMany(d => d.Cards).Count(c => c.IsActive),
                db.AccessLogs
                    .Where(a => a.UserId == u.Id)
                    .OrderByDescending(a => a.LoggedInAt)
                    .Select(a => (DateTime?)a.LoggedInAt)
                    .FirstOrDefault()
            ))
            .ToListAsync();

        return new PagedResult<AdminUserListDto>(items, total, page, pageSize);
    }

    public async Task<Result<AdminUserDetailDto>> GetUserDetailAsync(Guid userId)
    {
        var user = await db.Users
            .AsNoTracking()
            .Include(u => u.Decks.Where(d => d.IsActive))
                .ThenInclude(d => d.Cards.Where(c => c.IsActive))
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            return Result<AdminUserDetailDto>.Failure("Utilizador não encontrado.");

        var decks = user.Decks.Select(d => new AdminDeckDto(
            d.Id,
            d.Name,
            d.Language,
            d.NativeLanguage,
            d.Cards.Count,
            d.CreatedAt,
            d.Cards.Select(c => new AdminCardDto(
                c.Id, c.Front, c.Back, c.Pronunciation,
                c.AudioPath, c.CefrLevel?.ToString()
            )).ToList()
        )).ToList();

        return Result<AdminUserDetailDto>.Success(new AdminUserDetailDto(
            user.Id, user.Name, user.Email!, user.UserType.ToString(),
            user.IsEnabled, user.CreatedAt, user.ProfileImageUrl, decks));
    }

    public async Task<PagedResult<AccessLogDto>> GetAccessLogsAsync(AccessLogFilterDto filter)
    {
        var query = db.AccessLogs.AsNoTracking().AsQueryable();
    
        if (filter.UserId.HasValue)
            query = query.Where(a => a.UserId == filter.UserId.Value);
    
        if (!string.IsNullOrWhiteSpace(filter.Platform))
            query = query.Where(a => a.Platform == filter.Platform);
    
        if (filter.DateFrom.HasValue)
            query = query.Where(a => a.LoggedInAt >= filter.DateFrom.Value);
    
        if (filter.DateTo.HasValue)
            query = query.Where(a => a.LoggedInAt <= filter.DateTo.Value.AddDays(1));
    
        var total = await query.CountAsync();
    
        // Join manual com Users (ApplicationUser) via UserId
        var items = await query
            .OrderByDescending(a => a.LoggedInAt)
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Join(db.Users,
                log  => log.UserId,
                user => user.Id,
                (log, user) => new AccessLogDto(
                    log.Id,
                    log.UserId,
                    user.Name,
                    user.Email!,
                    log.Platform,
                    log.IpAddress,
                    log.UserAgent,
                    log.LoggedInAt))
            .ToListAsync();
    
        return new PagedResult<AccessLogDto>(items, total, filter.Page, filter.PageSize);
    }
}