using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class StudySchedulerService(FluentFlowDbContext db) : IStudySchedulerService
{
    public async Task<Result<StudyPlanDto>> GetPlanAsync(Guid deckId, Guid userId, StudyMode mode)
    {
        var deck = await db.Decks.FirstOrDefaultAsync(d => d.Id == deckId && d.UserId == userId && d.IsActive);

        if (deck is null) return Result<StudyPlanDto>.Failure(LocalizationHelper.Get("Api.DeckNotFound"));

        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        // Cards já estudados hoje (para respeitar limites diários)
        var studiedTodayIds = await db.StudyReviews
            .Where(r => r.Session.DeckId == deckId
                     && r.Session.UserId  == userId
                     && r.Mode == mode
                     && r.ReviewedAt >= today)
            .Select(r => r.CardId)
            .Distinct()
            .ToListAsync();

        var allCards = await db.Cards
            .Where(c => c.DeckId == deckId && c.IsActive)
            .ToListAsync();

        var (overdue, dueCapped, newCards) = GetAvailableCards(allCards, studiedTodayIds, deck, mode, today, tomorrow);

        var plan = overdue
            .Concat(dueCapped)
            .Concat(newCards)
            .DistinctBy(c => c.Id)
            .Select(CardService.ToDto)
            .ToList();

        return Result<StudyPlanDto>.Success(new StudyPlanDto(
            deckId, mode,
            NewCards: newCards.Count,
            ReviewCards: dueCapped.Count,
            OverdueCards: overdue.Count,
            Cards: plan));
    }

    /// <summary>
    /// Selecção de cards disponíveis para um modo, num determinado dia — a MESMA lógica usada
    /// pelo plano de estudo real. Partilhada com StudySessionService.GetDashboardAsync para que
    /// os números do Dashboard/Detalhes do Deck nunca divirjam do que a sessão de estudo (Web/App)
    /// efectivamente oferece.
    /// Overdue nunca é cortado por MaxReviewsPerDay; só "due hoje" respeita esse limite.
    /// </summary>
    public static (List<Card> Overdue, List<Card> DueCapped, List<Card> NewCards) GetAvailableCards(
        List<Card> allCards,
        List<Guid> studiedTodayIds,
        Deck deck,
        StudyMode mode,
        DateTime today,
        DateTime tomorrow)
    {
        // Overdue — passaram da data de revisão (têm nextReview definido e é anterior a hoje)
        var overdue = allCards
            .Where(c => GetNextReview(c, mode).HasValue
                     && GetNextReview(c, mode)!.Value.Date < today
                     && !studiedTodayIds.Contains(c.Id))
            .OrderBy(c => GetNextReview(c, mode))
            .ToList();

        // Due today — nextReview é hoje
        var due = allCards
            .Where(c => GetNextReview(c, mode).HasValue
                     && GetNextReview(c, mode)!.Value.Date >= today
                     && GetNextReview(c, mode)!.Value.Date <  tomorrow
                     && !studiedTodayIds.Contains(c.Id))
            .ToList();

        // New — nunca estudados neste modo:
        //   repetitions == 0 E nextReview == null (nunca foram revistos)
        //   Excluir cards que já estão no overdue ou due (têm nextReview definido)
        var newCards = allCards
            .Where(c => GetRepetitions(c, mode) == 0
                     && !GetNextReview(c, mode).HasValue
                     && !studiedTodayIds.Contains(c.Id))
            .Take(deck.MaxNewCardsPerDay)
            .ToList();

        // Montar plano respeitando MaxReviewsPerDay
        // IMPORTANTE: o limite diário aplica-se apenas aos cards "due hoje" (ainda não atrasados).
        // Cards overdue NUNCA podem ser cortados pelo limite — senão, assim que o utilizador atinge
        // o limite de revisões do dia, os cards atrasados desaparecem da sessão (mesmo continuando
        // a aparecer no dashboard), e o atraso acumula-se indefinidamente sem forma de o recuperar.
        var reviewSlots = deck.MaxReviewsPerDay - studiedTodayIds.Count;
        reviewSlots = Math.Max(0, reviewSlots);

        var dueCapped = due.Take(reviewSlots).ToList();

        return (overdue, dueCapped, newCards);
    }

    private static DateTime? GetNextReview(Card c, StudyMode mode) =>
        mode == StudyMode.Listening ? c.ListeningNextReview : c.SpeakingNextReview;

    private static int GetRepetitions(Card c, StudyMode mode) =>
        mode == StudyMode.Listening ? c.ListeningRepetitions : c.SpeakingRepetitions;
}