using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface ICardService
{
    Task<PagedResult<CardDto>> GetByDeckAsync(Guid deckId, Guid userId, int page, int pageSize);
    Task<Result<CardDto>> GetByIdAsync(Guid id, Guid userId);
    Task<Result<CardDto>> CreateAsync(Guid deckId, CreateCardDto dto, Guid userId);
    Task<Result<CardDto>> UpdateAsync(Guid id, UpdateCardDto dto, Guid userId);
    Task<Result> DeleteAsync(Guid id, Guid userId);
}