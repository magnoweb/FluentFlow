using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface IDeckService
{
    Task<PagedResult<DeckDto>> GetAllAsync(Guid userId, int page, int pageSize);
    Task<Result<DeckDto>> GetByIdAsync(Guid id, Guid userId);
    Task<Result<DeckDto>> CreateAsync(CreateDeckDto dto, Guid userId);
    Task<Result<DeckDto>> UpdateAsync(Guid id, UpdateDeckDto dto, Guid userId);
    Task<Result> DeleteAsync(Guid id, Guid userId);
}