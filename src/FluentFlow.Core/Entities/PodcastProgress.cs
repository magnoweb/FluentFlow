using FluentFlow.Core.Entities.Base;

namespace FluentFlow.Core.Entities;

/// <summary>Progresso de um utilizador num episódio de podcast.</summary>
public class PodcastProgress : BaseEntity
{
    public Guid UserId { get; set; }

    public Guid PodcastEpisodeId { get; set; }
    public PodcastEpisode PodcastEpisode { get; set; } = null!;

    /// <summary>Última posição ouvida, em ms (sempre na escala da versão normal).</summary>
    public int PositionMs { get; set; }

    /// <summary>Duração do episódio quando o progresso foi gravado (ms).</summary>
    public int DurationMs { get; set; }

    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }

    /// <summary>Número de vezes que o episódio foi ouvido até ao fim.</summary>
    public int PlayCount { get; set; }

    public bool IsFavorite { get; set; }

    public DateTime LastPlayedAt { get; set; } = DateTime.UtcNow;
}
