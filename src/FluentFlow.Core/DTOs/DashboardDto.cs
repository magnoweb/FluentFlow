namespace FluentFlow.Core.DTOs;

public record DashboardDto(
    int TotalCards,
    int DueToday,
    int NewToday,
    int StudiedToday,
    double AverageEaseFactor,
    IReadOnlyList<DailyStatDto> Last30Days
);

public record DailyStatDto(
    DateTime Date,
    int CardsReviewed,
    int CardsNew,
    double AverageScore
);