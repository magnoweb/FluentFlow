namespace FluentFlow.Core.DTOs.Decks;

public record DeckDto(
    Guid Id,
    string Name,
    string? Description,
    string Language,
    string NativeLanguage,
    int MaxNewCardsPerDay,
    int MaxReviewsPerDay,
    int TotalCards,
    DateTime CreatedAt
);

public record CreateDeckDto(
    string Name,
    string? Description,
    string Language,
    string NativeLanguage,
    int MaxNewCardsPerDay = 20,
    int MaxReviewsPerDay = 100
);

public record UpdateDeckDto(
    string Name,
    string? Description,
    int MaxNewCardsPerDay,
    int MaxReviewsPerDay
);