using FluentFlow.Core.Entities.Base;

namespace FluentFlow.Core.Entities;

/// <summary>
/// Episódio de podcast de um utilizador (enviado pela web a partir dos ficheiros
/// gerados pelo FluentFlow.PodcastGenerator: {id}.json + {id}.mp3 [+ {id}.slow.mp3]).
/// </summary>
public class PodcastEpisode : BaseEntity
{
    public Guid UserId { get; set; }

    /// <summary>Id do episódio no gerador (ex.: "shipit-s01e01"). Único por utilizador — reenviar substitui.</summary>
    public string ExternalId { get; set; } = null!;

    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = "en-US";
    public string? Level { get; set; }
    public string? Series { get; set; }
    public int? Season { get; set; }
    public int? EpisodeNumber { get; set; }
    public int DurationMs { get; set; }

    /// <summary>Caminho no storage (relativo a App_Data/Uploads), ex.: "podcasts/{userId}/shipit-s01e01.mp3".</summary>
    public string AudioPath { get; set; } = null!;
    public string? SlowAudioPath { get; set; }

    /// <summary>Factor de tempo da versão lenta (ex.: 0.85).</summary>
    public double? SlowTempo { get; set; }

    /// <summary>Transcrição sincronizada (JSON com a lista de linhas).</summary>
    public string TranscriptJson { get; set; } = "[]";

    public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<PodcastProgress> Progress { get; set; } = new List<PodcastProgress>();
}
