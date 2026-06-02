namespace FluentFlow.Core.DTOs;

public record CardDto(
    Guid Id,
    Guid DeckId,
    string Front,
    string Back,
    string? Pronunciation,
    string? AudioPath,
    string? CefrLevel, // ← "A1", "A2", ..., "C2"
    string? CefrLevelLabel, // ← "Iniciante", "Elementar", etc.
    string? CefrLevelColor,
    // Listening SM-2
    int ListeningRepetitions,
    int ListeningInterval,
    DateTime? ListeningNextReview,
    // Speaking SM-2
    int SpeakingRepetitions,
    int SpeakingInterval,
    DateTime? SpeakingNextReview,
    DateTime CreatedAt
);

public record CreateCardDto
{
    public string Front { get; set; } = null!;
    public string Back { get; set; } = null!;
    public string? Pronunciation { get; set; }
};

public record UpdateCardDto(
    string Front,
    string Back,
    string? Pronunciation,
    string? AudioPath = null
);

public record CardAudioDto(string AudioPath, string AudioUrl);