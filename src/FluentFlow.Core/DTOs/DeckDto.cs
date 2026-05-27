namespace FluentFlow.Core.DTOs;

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

public class CreateDeckDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;
    public string NativeLanguage { get; set; } = null!;
    public int MaxNewCardsPerDay { get; set; } = 20;
    public int MaxReviewsPerDay { get; set; } = 100;
}

public class UpdateDeckDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int MaxNewCardsPerDay { get; set; }
    public int MaxReviewsPerDay { get; set; }
}