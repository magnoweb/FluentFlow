namespace FluentFlow.Core.DTOs;

public record AdminUserListDto(
    Guid Id,
    string Name,
    string Email,
    string UserType,
    bool IsEnabled,
    DateTime CreatedAt,
    int DeckCount,
    int TotalCards,
    DateTime? LastLoginAt
);

public record AdminUserDetailDto(
    Guid Id,
    string Name,
    string Email,
    string UserType,
    bool IsEnabled,
    DateTime CreatedAt,
    string? ProfileImageUrl,
    IReadOnlyList<AdminDeckDto> Decks
);

public record AdminDeckDto(
    Guid Id,
    string Name,
    string Language,
    string NativeLanguage,
    int TotalCards,
    DateTime CreatedAt,
    IReadOnlyList<AdminCardDto> Cards
);

public record AdminCardDto(
    Guid Id,
    string Front,
    string Back,
    string? Pronunciation,
    string? AudioPath,
    string? CefrLevel
);