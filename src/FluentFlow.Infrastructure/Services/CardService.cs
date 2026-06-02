using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class CardService(FluentFlowDbContext db) : ICardService
{
    public async Task<PagedResult<CardDto>> GetByDeckAsync(
        Guid deckId, Guid userId, int page, int pageSize)
    {
        // Confirmar que o deck pertence ao utilizador
        var deckExists = await db.Decks
            .AnyAsync(d => d.Id == deckId && d.UserId == userId && d.IsActive);

        if (!deckExists) return new PagedResult<CardDto>([], 0, page, pageSize);

        var query = db.Cards
            .Where(c => c.DeckId == deckId && c.IsActive)
            .OrderBy(c => c.CreatedAt);

        var total = await query.CountAsync();
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(c => ToDto(c))
            .ToListAsync();

        return new PagedResult<CardDto>(items, total, page, pageSize);
    }

    public async Task<Result<CardDto>> GetByIdAsync(Guid id, Guid userId)
    {
        var card = await db.Cards
            .Include(c => c.Deck)
            .FirstOrDefaultAsync(c => c.Id == id && c.Deck.UserId == userId && c.IsActive);

        return card is null
            ? Result<CardDto>.Failure("Card não encontrado.")
            : Result<CardDto>.Success(ToDto(card));
    }

    public async Task<Result<CardDto>> CreateAsync(Guid deckId, CreateCardDto dto, Guid userId)
    {
        var deck = await db.Decks
            .FirstOrDefaultAsync(d => d.Id == deckId && d.UserId == userId && d.IsActive);

        if (deck is null) return Result<CardDto>.Failure("Deck não encontrado.");
        
        var cefrLevel = CefrCalculator.Calculate(dto.Front);

        var card = new Card
        {
            DeckId        = deckId,
            Front         = dto.Front,
            Back          = dto.Back,
            Pronunciation = dto.Pronunciation,
            CefrLevel     = cefrLevel
        };

        db.Cards.Add(card);
        await db.SaveChangesAsync();
        return Result<CardDto>.Success(ToDto(card));
    }

    public async Task<Result<CardDto>> UpdateAsync(Guid id, UpdateCardDto dto, Guid userId)
    {
        var card = await db.Cards
            .Include(c => c.Deck)
            .FirstOrDefaultAsync(c => c.Id == id && c.Deck.UserId == userId && c.IsActive);

        if (card is null) return Result<CardDto>.Failure("Card não encontrado.");

        card.Front = dto.Front;
        card.Back = dto.Back;
        card.Pronunciation = dto.Pronunciation;
        card.CefrLevel = CefrCalculator.Calculate(dto.Front);
        
        if (dto.AudioPath is not null)
            card.AudioPath = dto.AudioPath == "" ? null : dto.AudioPath;

        await db.SaveChangesAsync();
        return Result<CardDto>.Success(ToDto(card));
    }

    public async Task<Result> DeleteAsync(Guid id, Guid userId)
    {
        var card = await db.Cards
            .Include(c => c.Deck)
            .FirstOrDefaultAsync(c => c.Id == id && c.Deck.UserId == userId && c.IsActive);

        if (card is null) return Result.Failure("Card não encontrado.");

        card.IsActive = false;
        await db.SaveChangesAsync();
        return Result.Success();
    }

    internal static CardDto ToDto(Card c) => new(
        c.Id, c.DeckId, c.Front, c.Back, c.Pronunciation, c.AudioPath, 
        c.CefrLevel?.ToString(), c.CefrLevel.HasValue ? CefrCalculator.GetLabel(c.CefrLevel.Value) : null, c.CefrLevel.HasValue ? CefrCalculator.GetColor(c.CefrLevel.Value) : null,
        c.ListeningRepetitions, c.ListeningInterval, c.ListeningNextReview,
        c.SpeakingRepetitions,  c.SpeakingInterval,  c.SpeakingNextReview,
        c.CreatedAt);
}