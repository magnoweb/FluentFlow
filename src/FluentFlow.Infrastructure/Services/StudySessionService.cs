using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class StudySessionService(FluentFlowDbContext db, IReviewService reviewService) : IStudySessionService
{
    public async Task<Result<Guid>> StartAsync(StartSessionDto dto, Guid userId)
    {
        var deck = await db.Decks.FirstOrDefaultAsync(d => d.Id == dto.DeckId && d.UserId == userId && d.IsActive);

        if (deck is null) return Result<Guid>.Failure("Deck não encontrado.");

        var session = new StudySession
        {
            DeckId = dto.DeckId,
            UserId = userId,
            Mode   = dto.Mode,
        };

        db.StudySessions.Add(session);
        await db.SaveChangesAsync();
        return Result<Guid>.Success(session.Id);
    }

    public async Task<Result> SubmitReviewAsync(SubmitReviewDto dto, Guid userId)
    {
        // Validar sessão
        var session = await db.StudySessions
            .FirstOrDefaultAsync(s => s.Id == dto.SessionId
                                   && s.UserId == userId
                                   && s.EndedAt == null);

        if (session is null) return Result.Failure("Sessão não encontrada ou já terminada.");

        // Validar card pertence ao deck da sessão
        var card = await db.Cards
            .FirstOrDefaultAsync(c => c.Id == dto.CardId
                                   && c.DeckId == session.DeckId
                                   && c.IsActive);

        if (card is null) return Result.Failure("Card não encontrado.");

        var previousInterval = session.Mode == StudyMode.Listening
            ? card.ListeningInterval
            : card.SpeakingInterval;

        // Aplicar SM-2
        reviewService.ApplySM2(card, session.Mode, dto.Score);

        var newInterval = session.Mode == StudyMode.Listening
            ? card.ListeningInterval
            : card.SpeakingInterval;

        // Registar review
        var review = new StudyReview
        {
            SessionId        = session.Id,
            CardId           = card.Id,
            Mode             = session.Mode,
            Score            = dto.Score,
            SimilarityScore  = dto.SimilarityScore,
            TranscribedText  = dto.TranscribedText,
            PreviousInterval = previousInterval,
            NewInterval      = newInterval,
        };

        db.StudyReviews.Add(review);
        session.ReviewedCards++;
        await db.SaveChangesAsync();

        return Result.Success();
    }

    public async Task<Result<SessionResultDto>> EndAsync(Guid sessionId, Guid userId)
    {
        var session = await db.StudySessions
            .Include(s => s.Reviews)
            .FirstOrDefaultAsync(s => s.Id == sessionId
                                   && s.UserId == userId
                                   && s.EndedAt == null);

        if (session is null) return Result<SessionResultDto>.Failure("Sessão não encontrada.");

        session.EndedAt     = DateTime.UtcNow;
        session.TotalCards  = session.Reviews.Count;

        var avg = session.Reviews.Any()
            ? session.Reviews.Average(r => r.Score)
            : 0.0;

        // Actualizar ReviewHistory
        await UpsertReviewHistoryAsync(session, avg);
        await db.SaveChangesAsync();

        return Result<SessionResultDto>.Success(new SessionResultDto(
            session.Id,
            session.TotalCards,
            session.ReviewedCards,
            Math.Round(avg, 2),
            session.EndedAt.Value - session.StartedAt));
    }

    public async Task<Result<DashboardDto>> GetDashboardAsync(Guid deckId, Guid userId)
    {
        var deck = await db.Decks
            .FirstOrDefaultAsync(d => d.Id == deckId && d.UserId == userId && d.IsActive);

        if (deck is null) return Result<DashboardDto>.Failure("Deck não encontrado.");

        var today    = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        var cards = await db.Cards
            .Where(c => c.DeckId == deckId && c.IsActive)
            .ToListAsync();

        var studiedToday = await db.StudyReviews
            .Where(r => r.Session.DeckId == deckId
                     && r.Session.UserId  == userId
                     && r.ReviewedAt      >= today)
            .Select(r => r.CardId)
            .Distinct()
            .CountAsync();

        var dueToday = cards
            .Count(c => (c.ListeningNextReview >= today && c.ListeningNextReview < tomorrow)
                     || (c.SpeakingNextReview  >= today && c.SpeakingNextReview  < tomorrow));

        var newToday = cards.Count(c =>
            c.ListeningRepetitions == 0 && c.SpeakingRepetitions == 0);

        var avgEF = cards.Any()
            ? cards.Average(c => (c.ListeningEaseFactor + c.SpeakingEaseFactor) / 2)
            : 2.5;

        var last30 = await db.ReviewHistory
            .Where(h => h.DeckId == deckId
                     && h.UserId  == userId
                     && h.Date    >= today.AddDays(-30))
            .OrderBy(h => h.Date)
            .Select(h => new DailyStatDto(h.Date, h.CardsReviewed, h.CardsNew, h.AverageScore))
            .ToListAsync();

        return Result<DashboardDto>.Success(new DashboardDto(
            TotalCards:      cards.Count,
            DueToday:        dueToday,
            NewToday:        newToday,
            StudiedToday:    studiedToday,
            AverageEaseFactor: Math.Round(avgEF, 2),
            Last30Days:      last30));
    }

    public async Task<PagedResult<StudySessionListDto>> GetSessionsAsync(Guid userId, Guid? deckId, string? mode, int page, int pageSize)
    {
        var query = db.StudySessions
            .Include(s => s.Deck)
            .Where(s => s.UserId == userId)
            .AsQueryable();

        if (deckId.HasValue)
            query = query.Where(s => s.DeckId == deckId.Value);
        
        if (!string.IsNullOrWhiteSpace(mode) && Enum.TryParse<StudyMode>(mode, ignoreCase: true, out var studyMode))
            query = query.Where(s => s.Mode == studyMode);

        var total = await query.CountAsync();

        var items = await query
            .OrderByDescending(s => s.StartedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(s => new StudySessionListDto(
                s.Id,
                s.DeckId,
                s.Deck.Name,
                s.Mode.ToString(),
                s.StartedAt,
                s.EndedAt,
                s.TotalCards,
                s.ReviewedCards,
                s.Reviews.Any()
                    ? s.Reviews.Average(r => r.Score)
                    : 0.0,
                s.EndedAt.HasValue
                    ? s.EndedAt.Value - s.StartedAt
                    : (TimeSpan?)null
            ))
            .ToListAsync();

        return new PagedResult<StudySessionListDto>(items, total, page, pageSize);
    }

    public async Task<Result<StudySessionDetailDto>> GetSessionDetailAsync(Guid sessionId, Guid userId)
    {
        var session = await db.StudySessions
            .Include(s => s.Deck)
            .Include(s => s.Reviews)
                .ThenInclude(r => r.Card)
            .FirstOrDefaultAsync(s => s.Id == sessionId
                                   && s.UserId == userId);

        if (session is null)
            return Result<StudySessionDetailDto>.Failure("Sessão não encontrada.");

        var reviews = session.Reviews
            .OrderBy(r => r.ReviewedAt)
            .Select(r => new StudyReviewDto(
                r.CardId,
                r.Card.Front,
                r.Card.Back,
                r.Card.CefrLevel?.ToString(),
                r.Score,
                r.SimilarityScore,
                r.TranscribedText,
                r.PreviousInterval,
                r.NewInterval,
                r.ReviewedAt
            ))
            .ToList();

        var avg = reviews.Any() ? reviews.Average(r => r.Score) : 0.0;

        return Result<StudySessionDetailDto>.Success(new StudySessionDetailDto(
            session.Id,
            session.DeckId,
            session.Deck.Name,
            session.Mode.ToString(),
            session.StartedAt,
            session.EndedAt,
            session.TotalCards,
            session.ReviewedCards,
            Math.Round(avg, 2),
            session.EndedAt.HasValue
                ? session.EndedAt.Value - session.StartedAt
                : null,
            reviews
        ));
    }
    
    private async Task UpsertReviewHistoryAsync(StudySession session, double avgScore)
    {
        var today = DateTime.UtcNow.Date;
        var existing = await db.ReviewHistory
            .FirstOrDefaultAsync(h => h.DeckId == session.DeckId
                                   && h.UserId  == session.UserId
                                   && h.Date    == today
                                   && h.Mode    == session.Mode);

        var newCount = session.Reviews.Count(r => r.PreviousInterval == 0);

        if (existing is null)
        {
            db.ReviewHistory.Add(new ReviewHistory
            {
                UserId        = session.UserId,
                DeckId        = session.DeckId,
                Date          = today,
                Mode          = session.Mode,
                CardsReviewed = session.Reviews.Count,
                CardsNew      = newCount,
                AverageScore  = avgScore,
            });
        }
        else
        {
            existing.CardsReviewed += session.Reviews.Count;
            existing.CardsNew      += newCount;
            existing.AverageScore   =
                (existing.AverageScore + avgScore) / 2;
        }
    }
}