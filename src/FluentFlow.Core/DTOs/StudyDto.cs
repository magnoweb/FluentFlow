using FluentFlow.Core.Enums;

namespace FluentFlow.Core.DTOs;

public record StudyPlanDto(
    Guid DeckId,
    StudyMode Mode,
    int NewCards,
    int ReviewCards,
    int OverdueCards,
    IReadOnlyList<CardDto> Cards
);

public record StartSessionDto(
    Guid DeckId,
    StudyMode Mode
);

public record SubmitReviewDto(
    Guid SessionId,
    Guid CardId,
    int Score, // 0–5 (SM-2)
    double? SimilarityScore, // Speaking: 0.0–1.0
    string? TranscribedText
);

public record SessionResultDto(
    Guid SessionId,
    int TotalCards,
    int ReviewedCards,
    double AverageScore,
    TimeSpan Duration
);

/// <summary>
/// Sessão de estudo deixada em aberto (sem EndAsync) que pode ser retomada —
/// só é devolvida quando é, de facto, a sessão mais recente deste deck+modo
/// (ou seja, não existe nenhuma sessão mais nova a seguir, terminada ou não).
/// </summary>
public record ResumableSessionDto(
    Guid SessionId,
    DateTime StartedAt,
    int ReviewedCards,
    IReadOnlyList<Guid> ReviewedCardIds
);