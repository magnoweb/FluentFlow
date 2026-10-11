namespace FluentFlow.Core.DTOs;

/// <summary>Estado do utilizador num episódio.</summary>
public record PodcastProgressDto(
    int PositionMs,
    bool IsCompleted,
    DateTime? CompletedAt,
    DateTime LastPlayedAt,
    int PlayCount,
    bool IsFavorite
);

public record PodcastEpisodeDto(
    // Guid do episódio (como string, para os clientes).
    string Id,
    string Title,
    string? Description,
    string Language,
    string? Level,
    string? Series,
    int? Season,
    int? EpisodeNumber,
    int DurationMs,
    // Caminho relativo à API (ex.: "uploads/podcasts/{userId}/shipit-s01e01.mp3").
    string AudioPath,
    string? SlowAudioPath,
    double? SlowTempo,
    PodcastProgressDto? Progress
);

public record PodcastGroupDto(
    // "general" para episódios sem série; senão o nome normalizado da série + temporada.
    string Key,
    string? Series,
    int? Season,
    int TotalEpisodes,
    int CompletedEpisodes,
    IReadOnlyList<PodcastEpisodeDto> Episodes
);

public record PodcastStatsDto(
    int TotalEpisodes,
    int CompletedEpisodes,
    int InProgressEpisodes,
    int ListenedMinutes
);

public record PodcastLibraryDto(
    IReadOnlyList<PodcastGroupDto> Groups,
    // Episódio a meio mais recente (para "Continuar de onde parou").
    PodcastEpisodeDto? ContinueListening,
    // Próximo episódio por ouvir da série/grupo mais recente.
    PodcastEpisodeDto? UpNext,
    PodcastStatsDto Stats
);

public record PodcastLineDto(
    int Index,
    string? Section,
    string Speaker,
    string Text,
    string? Translation,
    int StartMs,
    int EndMs
);

public record PodcastEpisodeDetailDto(
    PodcastEpisodeDto Episode,
    IReadOnlyList<PodcastLineDto> Lines,
    string? PreviousEpisodeId,
    string? NextEpisodeId,
    string? NextEpisodeTitle
);

public class UpdatePodcastProgressDto
{
    // Posição actual em ms (escala da versão normal).
    public int PositionMs { get; set; }

    // true quando o áudio chegou ao fim.
    public bool Completed { get; set; }
}

public class SetPodcastFavoriteDto
{
    public bool IsFavorite { get; set; }
}

/// <summary>Resultado do envio de um episódio.</summary>
public record PodcastUploadResultDto(
    PodcastEpisodeDto Episode,
    // true quando já existia um episódio com o mesmo id do gerador (foi substituído).
    bool Replaced
);
