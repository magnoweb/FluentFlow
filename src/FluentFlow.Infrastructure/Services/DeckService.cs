using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FluentFlow.Infrastructure.Services;

public class DeckService(FluentFlowDbContext db, ILogger<DeckService> logger) : IDeckService
{
    public async Task<PagedResult<DeckDto>> GetAllAsync(Guid userId, int page, int pageSize)
    {
        var query = db.Decks
            .Where(d => d.UserId == userId && d.IsActive)
            .OrderByDescending(d => d.CreatedAt);

        var total = await query.CountAsync();
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(d => ToDto(d, d.Cards.Count(c => c.IsActive)))
            .ToListAsync();

        return new PagedResult<DeckDto>(items, total, page, pageSize);
    }

    public async Task<Result<DeckDto>> GetByIdAsync(Guid id, Guid userId)
    {
        var deck = await db.Decks
            .Include(d => d.Cards.Where(c => c.IsActive))
            .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId && d.IsActive);

        return deck is null
            ? Result<DeckDto>.Failure("Deck não encontrado.")
            : Result<DeckDto>.Success(ToDto(deck, deck.Cards.Count));
    }

    public async Task<Result<DeckDto>> CreateAsync(CreateDeckDto dto, Guid userId)
    {
        var deck = new Deck
        {
            UserId          = userId,
            Name            = dto.Name,
            Description     = dto.Description,
            Language        = dto.Language,
            NativeLanguage  = dto.NativeLanguage,
            MaxNewCardsPerDay   = dto.MaxNewCardsPerDay,
            MaxReviewsPerDay    = dto.MaxReviewsPerDay,
        };

        db.Decks.Add(deck);
        await db.SaveChangesAsync();
        return Result<DeckDto>.Success(ToDto(deck, 0));
    }

    public async Task<Result<DeckDto>> UpdateAsync(Guid id, UpdateDeckDto dto, Guid userId)
    {
        var deck = await db.Decks.FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId && d.IsActive);

        if (deck is null) return Result<DeckDto>.Failure("Deck não encontrado.");

        deck.Name                = dto.Name;
        deck.Description         = dto.Description;
        deck.MaxNewCardsPerDay   = dto.MaxNewCardsPerDay;
        deck.MaxReviewsPerDay    = dto.MaxReviewsPerDay;

        await db.SaveChangesAsync();
        return Result<DeckDto>.Success(ToDto(deck, 0));
    }

    public async Task<Result> DeleteAsync(Guid id, Guid userId)
    {
        var deck = await db.Decks.FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId && d.IsActive);

        if (deck is null) return Result.Failure("Deck não encontrado.");

        deck.IsActive = false; // soft delete
        await db.SaveChangesAsync();
        return Result.Success();
    }

    private static DeckDto ToDto(Deck d, int totalCards) => new(
        d.Id, d.Name, d.Description, d.Language, d.NativeLanguage,
        d.MaxNewCardsPerDay, d.MaxReviewsPerDay, totalCards, d.CreatedAt);
}