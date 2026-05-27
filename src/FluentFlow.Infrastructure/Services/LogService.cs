using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class LogService(FluentFlowDbContext db) : ILogService
{
    public async Task<PagedResult<LogDto>> GetPagedAsync(LogFilterDto filter)
    {
        var query = db.Logs.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Level))
            query = query.Where(l => l.Level == filter.Level);

        if (!string.IsNullOrWhiteSpace(filter.Search))
            query = query.Where(l =>
                (l.Message != null && l.Message.Contains(filter.Search)) ||
                (l.Exception != null && l.Exception.Contains(filter.Search)));

        if (filter.DateFrom.HasValue)
            query = query.Where(l => l.TimeStamp >= filter.DateFrom.Value);

        if (filter.DateTo.HasValue)
            query = query.Where(l => l.TimeStamp <= filter.DateTo.Value.AddDays(1));

        var total = await query.CountAsync();

        var items = await query
            .OrderByDescending(l => l.TimeStamp)
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Select(l => new LogDto(
                l.Id,
                l.Level,
                l.Message,
                l.TimeStamp,
                l.Exception != null,
                l.UserId,
                l.CardId))
            .ToListAsync();

        return new PagedResult<LogDto>(items, total, filter.Page, filter.PageSize);
    }

    public async Task<LogDetailDto?> GetByIdAsync(int id)
    {
        var log = await db.Logs
            .AsNoTracking()
            .FirstOrDefaultAsync(l => l.Id == id);

        if (log is null) return null;

        return new LogDetailDto(
            log.Id, log.Level, log.Message, log.MessageTemplate,
            log.TimeStamp, log.Exception, log.Properties,
            log.LogEvent, log.UserId, log.CardId);
    }
}