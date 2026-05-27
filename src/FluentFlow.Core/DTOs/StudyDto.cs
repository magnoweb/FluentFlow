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
    int Score,                      // 0–5 (SM-2)
    double? SimilarityScore,        // Speaking: 0.0–1.0
    string? TranscribedText
);

public record SessionResultDto(
    Guid SessionId,
    int TotalCards,
    int ReviewedCards,
    double AverageScore,
    TimeSpan Duration
);