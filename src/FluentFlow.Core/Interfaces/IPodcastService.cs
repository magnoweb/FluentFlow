using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

/// <summary>Ficheiro de áudio enviado com um episódio.</summary>
public sealed record PodcastUploadFile(Stream Content, string FileName);

public interface IPodcastService
{
    /// <summary>Biblioteca do utilizador agrupada (séries / geral) com o progresso.</summary>
    Task<PodcastLibraryDto> GetLibraryAsync(Guid userId);

    /// <summary>Episódio com transcrição sincronizada e navegação anterior/seguinte.</summary>
    Task<Result<PodcastEpisodeDetailDto>> GetEpisodeAsync(Guid episodeId, Guid userId);

    /// <summary>
    /// Cria (ou substitui, se o utilizador já tiver um episódio com o mesmo id do gerador)
    /// um episódio a partir da transcrição JSON do PodcastGenerator e dos áudios.
    /// </summary>
    Task<Result<PodcastUploadResultDto>> UploadAsync(
        Stream transcriptJson, PodcastUploadFile audio, PodcastUploadFile? slowAudio, Guid userId);

    /// <summary>Elimina o episódio, os ficheiros e o progresso associado.</summary>
    Task<Result> DeleteAsync(Guid episodeId, Guid userId);

    /// <summary>Grava a posição; marca como ouvido quando chega ao fim (ou ≥ 95%).</summary>
    Task<Result<PodcastProgressDto>> UpdateProgressAsync(Guid episodeId, UpdatePodcastProgressDto dto, Guid userId);

    /// <summary>Marca o episódio como não ouvido e volta ao início (mantém o favorito).</summary>
    Task<Result<PodcastProgressDto>> ResetProgressAsync(Guid episodeId, Guid userId);

    Task<Result<PodcastProgressDto>> SetFavoriteAsync(Guid episodeId, bool isFavorite, Guid userId);
}
