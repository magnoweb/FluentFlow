using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class StudySchedulerService(FluentFlowDbContext db) : IStudySchedulerService
{
    public async Task<Result<StudyPlanDto>> GetPlanAsync(Guid deckId, Guid userId, StudyMode mode)
    {
        var deck = await db.Decks
            .FirstOrDefaultAsync(d => d.Id == deckId && d.UserId == userId && d.IsActive);

        if (deck is null) return Result<StudyPlanDto>.Failure("Deck não encontrado.");

        var today     = DateTime.UtcNow.Date;
        var tomorrow  = today.AddDays(1);

        // Cards já estudados hoje (para respeitar limites diários)
        var studiedTodayIds = await db.StudyReviews
            .Where(r => r.Session.DeckId == deckId
                     && r.Session.UserId  == userId
                     && r.Mode            == mode
                     && r.ReviewedAt      >= today)
            .Select(r => r.CardId)
            .Distinct()
            .ToListAsync();

        var allCards = await db.Cards
            .Where(c => c.DeckId == deckId && c.IsActive)
            .ToListAsync();

        // Overdue — passaram da data de revisão
        var overdue = allCards
            .Where(c => GetNextReview(c, mode) < today
                     && !studiedTodayIds.Contains(c.Id))
            .OrderBy(c => GetNextReview(c, mode))
            .ToList();

        // Due today
        var due = allCards
            .Where(c => GetNextReview(c, mode) >= today
                     && GetNextReview(c, mode) <  tomorrow
                     && !studiedTodayIds.Contains(c.Id))
            .ToList();

        // New — nunca estudados neste modo
        var newCards = allCards
            .Where(c => GetRepetitions(c, mode) == 0
                     && !studiedTodayIds.Contains(c.Id))
            .Take(deck.MaxNewCardsPerDay)
            .ToList();

        // Montar plano respeitando MaxReviewsPerDay
        var reviewSlots = deck.MaxReviewsPerDay - studiedTodayIds.Count;
        reviewSlots = Math.Max(0, reviewSlots);

        var plan = overdue
            .Concat(due)
            .Take(reviewSlots)
            .Concat(newCards)
            .DistinctBy(c => c.Id)
            .Select(CardService.ToDto)
            .ToList();

        return Result<StudyPlanDto>.Success(new StudyPlanDto(
            deckId, mode,
            NewCards:     newCards.Count,
            ReviewCards:  due.Count,
            OverdueCards: overdue.Count,
            Cards:        plan));
    }

    private static DateTime? GetNextReview(Core.Entities.Card c, StudyMode mode) =>
        mode == StudyMode.Listening ? c.ListeningNextReview : c.SpeakingNextReview;

    private static int GetRepetitions(Core.Entities.Card c, StudyMode mode) =>
        mode == StudyMode.Listening ? c.ListeningRepetitions : c.SpeakingRepetitions;
}