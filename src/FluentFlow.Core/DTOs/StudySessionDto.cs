namespace FluentFlow.Core.DTOs;

public record StudySessionListDto(
    Guid      Id,
    Guid      DeckId,
    string    DeckName,
    string    Mode,
    DateTime  StartedAt,
    DateTime? EndedAt,
    int       TotalCards,
    int       ReviewedCards,
    double    AverageScore,
    TimeSpan? Duration
);

public record StudySessionDetailDto(
    Guid      Id,
    Guid      DeckId,
    string    DeckName,
    string    Mode,
    DateTime  StartedAt,
    DateTime? EndedAt,
    int       TotalCards,
    int       ReviewedCards,
    double    AverageScore,
    TimeSpan? Duration,
    IReadOnlyList<StudyReviewDto> Reviews
);

public record StudyReviewDto(
    Guid     CardId,
    string   CardFront,
    string   CardBack,
    string?  CefrLevel,
    int      Score,
    double?  SimilarityScore,
    string?  TranscribedText,
    int      PreviousInterval,
    int      NewInterval,
    DateTime ReviewedAt
)
{
    // Propriedade calculada — não faz parte do construtor
    public string ScoreLabel => Score switch
    {
        0 => "Nada",
        1 => "Errei",
        2 => "Difícil",
        3 => "Ok",
        4 => "Bem",
        5 => "Fácil",
        _ => $"{Score}"
    };
}