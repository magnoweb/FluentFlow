using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FluentFlow.Infrastructure.Services.Podcasts;

/// <summary>
/// Podcasts por utilizador (como os Decks): cada utilizador envia e gere os seus episódios.
/// Os áudios ficam no storage (App_Data/Uploads/podcasts/{userId}/…) e são servidos em /uploads.
/// </summary>
public class PodcastService(FluentFlowDbContext db, IStorageService storage, ILogger<PodcastService> logger) : IPodcastService
{
    /// <summary>A partir desta fração da duração, o episódio conta como ouvido.</summary>
    private const double CompletionThreshold = 0.95;

    public static readonly string[] AllowedAudioExtensions = [".mp3", ".m4a", ".ogg", ".wav"];

    // Episódio sem a transcrição (para listas)
    private sealed record EpisodeRow(
        Guid Id, string ExternalId, string Title, string? Description, string Language, string? Level,
        string? Series, int? Season, int? EpisodeNumber, int DurationMs,
        string AudioPath, string? SlowAudioPath, double? SlowTempo)
    {
        public string GroupKey => PodcastCatalog.GroupKey(Series, Season);
    }

    // ── Leitura ─────────────────────────────────────────────────────────────────

    public async Task<PodcastLibraryDto> GetLibraryAsync(Guid userId)
    {
        var episodes = await LoadEpisodesAsync(userId);
        var byId = episodes.ToDictionary(e => e.Id);
        var progress = await LoadProgressAsync(userId);

        var groups = episodes
            .GroupBy(e => e.GroupKey)
            .Select(g =>
            {
                var items = g.Select(e => ToDto(e, progress.GetValueOrDefault(e.Id))).ToList();
                var first = g.First();
                return new PodcastGroupDto(
                    g.Key, first.Series, first.Series is null ? null : first.Season ?? 1,
                    items.Count, items.Count(i => i.Progress?.IsCompleted == true), items);
            })
            .ToList();

        // Continuar de onde parou: o episódio a meio ouvido mais recentemente
        var continueEp = progress.Values
            .Where(p => !p.IsCompleted && p.PositionMs > 0)
            .OrderByDescending(p => p.LastPlayedAt)
            .Select(p => byId.GetValueOrDefault(p.PodcastEpisodeId))
            .FirstOrDefault(e => e is not null);

        // Próximo: no grupo do último episódio ouvido, o primeiro ainda não ouvido
        PodcastEpisodeDto? upNext = null;
        var lastPlayed = progress.Values
            .OrderByDescending(p => p.LastPlayedAt)
            .Select(p => byId.GetValueOrDefault(p.PodcastEpisodeId))
            .FirstOrDefault(e => e is not null);
        if (lastPlayed is not null)
        {
            var next = episodes.FirstOrDefault(e =>
                e.GroupKey == lastPlayed.GroupKey &&
                e.Id != continueEp?.Id &&
                progress.GetValueOrDefault(e.Id)?.IsCompleted != true);
            if (next is not null) upNext = ToDto(next, progress.GetValueOrDefault(next.Id));
        }

        var known = progress.Values.ToList();
        var listenedMs = known.Sum(p => (long)(p.IsCompleted ? Math.Max(p.DurationMs, 0) * Math.Max(p.PlayCount, 1) : p.PositionMs));

        var stats = new PodcastStatsDto(
            episodes.Count,
            known.Count(p => p.IsCompleted),
            known.Count(p => !p.IsCompleted && p.PositionMs > 0),
            (int)(listenedMs / 60_000));

        return new PodcastLibraryDto(
            groups,
            continueEp is null ? null : ToDto(continueEp, progress.GetValueOrDefault(continueEp.Id)),
            upNext,
            stats);
    }

    public async Task<Result<PodcastEpisodeDetailDto>> GetEpisodeAsync(Guid episodeId, Guid userId)
    {
        var entity = await db.PodcastEpisodes.AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == episodeId && e.UserId == userId);
        if (entity is null)
            return Result<PodcastEpisodeDetailDto>.Failure(LocalizationHelper.Get("Api.PodcastNotFound"));

        var progress = await db.PodcastProgress.AsNoTracking()
            .FirstOrDefaultAsync(p => p.UserId == userId && p.PodcastEpisodeId == episodeId);

        // Navegação dentro do mesmo grupo (série/temporada ou "geral")
        var groupKey = PodcastCatalog.GroupKey(entity.Series, entity.Season);
        var siblings = (await LoadEpisodesAsync(userId)).Where(e => e.GroupKey == groupKey).ToList();
        var index = siblings.FindIndex(e => e.Id == episodeId);
        var previous = index > 0 ? siblings[index - 1] : null;
        var next = index >= 0 && index < siblings.Count - 1 ? siblings[index + 1] : null;

        return Result<PodcastEpisodeDetailDto>.Success(new PodcastEpisodeDetailDto(
            ToDto(ToRow(entity), progress),
            PodcastCatalog.DeserializeLines(entity.TranscriptJson),
            previous?.Id.ToString(), next?.Id.ToString(), next?.Title));
    }

    // ── Envio / eliminação ──────────────────────────────────────────────────────

    public async Task<Result<PodcastUploadResultDto>> UploadAsync(
        Stream transcriptJson, PodcastUploadFile audio, PodcastUploadFile? slowAudio, Guid userId)
    {
        var transcript = await PodcastCatalog.ParseAsync(transcriptJson, Path.GetFileNameWithoutExtension(audio.FileName));
        if (transcript is null)
            return Result<PodcastUploadResultDto>.Failure(LocalizationHelper.Get("Api.PodcastInvalidTranscript"));

        foreach (var file in new[] { audio, slowAudio })
        {
            if (file is null) continue;
            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!AllowedAudioExtensions.Contains(ext))
                return Result<PodcastUploadResultDto>.Failure(
                    string.Format(LocalizationHelper.Get("Api.ExtensionNotSupportedDetailed"), ext));
        }

        var folder = $"podcasts/{userId}";
        string? audioPath = null, slowPath = null;
        try
        {
            audioPath = await storage.SaveAsync(audio.Content, transcript.Id + Path.GetExtension(audio.FileName), folder);
            if (slowAudio is not null)
                slowPath = await storage.SaveAsync(slowAudio.Content, transcript.Id + ".slow" + Path.GetExtension(slowAudio.FileName), folder);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Falha ao gravar os áudios do podcast {Id}", transcript.Id);
            await TryDeleteFilesAsync(audioPath, slowPath);
            return Result<PodcastUploadResultDto>.Failure(LocalizationHelper.Get("Api.FileSaveError"));
        }

        var entity = await db.PodcastEpisodes
            .FirstOrDefaultAsync(e => e.UserId == userId && e.ExternalId == transcript.Id);
        var replaced = entity is not null;
        string?[] oldFiles = replaced ? [entity!.AudioPath, entity.SlowAudioPath] : [];

        if (entity is null)
        {
            entity = new PodcastEpisode { UserId = userId, ExternalId = transcript.Id };
            db.PodcastEpisodes.Add(entity);
        }

        entity.Title = transcript.Title;
        entity.Description = transcript.Description;
        entity.Language = transcript.Language;
        entity.Level = transcript.Level;
        entity.Series = transcript.Series;
        entity.Season = transcript.Series is null ? null : transcript.Season ?? 1;
        entity.EpisodeNumber = transcript.EpisodeNumber;
        entity.DurationMs = transcript.DurationMs;
        entity.AudioPath = audioPath!;
        entity.SlowAudioPath = slowPath;
        entity.SlowTempo = slowPath is null ? null : transcript.SlowTempo ?? 0.85;
        entity.TranscriptJson = PodcastCatalog.SerializeLines(transcript.Lines);
        entity.GeneratedAt = transcript.GeneratedAtUtc;

        try
        {
            await db.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Falha ao gravar o podcast {Id}", transcript.Id);
            await TryDeleteFilesAsync(audioPath, slowPath);
            return Result<PodcastUploadResultDto>.Failure(LocalizationHelper.Get("Api.FileSaveError"));
        }

        // Só depois de gravar: apaga os ficheiros da versão anterior
        if (replaced) await TryDeleteFilesAsync(oldFiles);

        var progress = await db.PodcastProgress.AsNoTracking()
            .FirstOrDefaultAsync(p => p.UserId == userId && p.PodcastEpisodeId == entity.Id);

        return Result<PodcastUploadResultDto>.Success(new PodcastUploadResultDto(ToDto(ToRow(entity), progress), replaced));
    }

    public async Task<Result> DeleteAsync(Guid episodeId, Guid userId)
    {
        var entity = await db.PodcastEpisodes.FirstOrDefaultAsync(e => e.Id == episodeId && e.UserId == userId);
        if (entity is null)
            return Result.Failure(LocalizationHelper.Get("Api.PodcastNotFound"));

        var files = new[] { entity.AudioPath, entity.SlowAudioPath };
        db.PodcastEpisodes.Remove(entity); // o progresso vai em cascade
        await db.SaveChangesAsync();

        await TryDeleteFilesAsync(files);
        return Result.Success();
    }

    // ── Progresso ───────────────────────────────────────────────────────────────

    public async Task<Result<PodcastProgressDto>> UpdateProgressAsync(Guid episodeId, UpdatePodcastProgressDto dto, Guid userId)
    {
        var duration = await GetDurationAsync(episodeId, userId);
        if (duration is null)
            return Result<PodcastProgressDto>.Failure(LocalizationHelper.Get("Api.PodcastNotFound"));

        var entity = await GetOrCreateProgressAsync(episodeId, userId);
        var position = Math.Clamp(dto.PositionMs, 0, Math.Max(duration.Value, 0));
        var reachedEnd = dto.Completed || (duration > 0 && position >= duration * CompletionThreshold);

        entity.DurationMs = duration.Value;
        entity.LastPlayedAt = DateTime.UtcNow;

        if (reachedEnd)
        {
            // Conta uma nova audição só na transição para "ouvido" (ou ao reouvir até ao fim)
            if (!entity.IsCompleted || entity.PositionMs > 0)
                entity.PlayCount++;

            entity.IsCompleted = true;
            entity.CompletedAt = DateTime.UtcNow;
            entity.PositionMs = 0; // da próxima vez começa do início
        }
        else
        {
            entity.PositionMs = position;
        }

        await db.SaveChangesAsync();
        return Result<PodcastProgressDto>.Success(ToDto(entity));
    }

    public async Task<Result<PodcastProgressDto>> ResetProgressAsync(Guid episodeId, Guid userId)
    {
        var duration = await GetDurationAsync(episodeId, userId);
        if (duration is null)
            return Result<PodcastProgressDto>.Failure(LocalizationHelper.Get("Api.PodcastNotFound"));

        var entity = await GetOrCreateProgressAsync(episodeId, userId);
        entity.PositionMs = 0;
        entity.IsCompleted = false;
        entity.CompletedAt = null;
        entity.DurationMs = duration.Value;

        await db.SaveChangesAsync();
        return Result<PodcastProgressDto>.Success(ToDto(entity));
    }

    public async Task<Result<PodcastProgressDto>> SetFavoriteAsync(Guid episodeId, bool isFavorite, Guid userId)
    {
        var duration = await GetDurationAsync(episodeId, userId);
        if (duration is null)
            return Result<PodcastProgressDto>.Failure(LocalizationHelper.Get("Api.PodcastNotFound"));

        var entity = await GetOrCreateProgressAsync(episodeId, userId);
        entity.IsFavorite = isFavorite;
        entity.DurationMs = duration.Value;

        await db.SaveChangesAsync();
        return Result<PodcastProgressDto>.Success(ToDto(entity));
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    /// <summary>Episódios do utilizador ordenados: séries (nome/temporada/episódio) e "geral" no fim.</summary>
    private async Task<List<EpisodeRow>> LoadEpisodesAsync(Guid userId)
    {
        var rows = await db.PodcastEpisodes.AsNoTracking()
            .Where(e => e.UserId == userId)
            .Select(e => new EpisodeRow(
                e.Id, e.ExternalId, e.Title, e.Description, e.Language, e.Level,
                e.Series, e.Season, e.EpisodeNumber, e.DurationMs,
                e.AudioPath, e.SlowAudioPath, e.SlowTempo))
            .ToListAsync();

        return rows
            .OrderBy(e => e.Series is null ? 1 : 0)
            .ThenBy(e => e.Series, StringComparer.OrdinalIgnoreCase)
            .ThenBy(e => e.Season ?? 0)
            .ThenBy(e => e.EpisodeNumber ?? int.MaxValue)
            .ThenBy(e => e.ExternalId, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private Task<int?> GetDurationAsync(Guid episodeId, Guid userId) =>
        db.PodcastEpisodes.AsNoTracking()
            .Where(e => e.Id == episodeId && e.UserId == userId)
            .Select(e => (int?)e.DurationMs)
            .FirstOrDefaultAsync();

    private async Task<Dictionary<Guid, PodcastProgress>> LoadProgressAsync(Guid userId) =>
        await db.PodcastProgress.AsNoTracking()
            .Where(p => p.UserId == userId)
            .ToDictionaryAsync(p => p.PodcastEpisodeId);

    private async Task<PodcastProgress> GetOrCreateProgressAsync(Guid episodeId, Guid userId)
    {
        var entity = await db.PodcastProgress.FirstOrDefaultAsync(p => p.UserId == userId && p.PodcastEpisodeId == episodeId);
        if (entity is not null) return entity;

        entity = new PodcastProgress { UserId = userId, PodcastEpisodeId = episodeId, LastPlayedAt = DateTime.UtcNow };
        db.PodcastProgress.Add(entity);
        return entity;
    }

    private async Task TryDeleteFilesAsync(params string?[] paths)
    {
        foreach (var path in paths)
        {
            if (string.IsNullOrWhiteSpace(path)) continue;
            try { await storage.DeleteAsync(path); }
            catch (Exception ex) { logger.LogWarning(ex, "Não foi possível apagar o ficheiro {Path}", path); }
        }
    }

    private static EpisodeRow ToRow(PodcastEpisode e) => new(
        e.Id, e.ExternalId, e.Title, e.Description, e.Language, e.Level,
        e.Series, e.Season, e.EpisodeNumber, e.DurationMs,
        e.AudioPath, e.SlowAudioPath, e.SlowTempo);

    /// <summary>Caminho público (relativo à API) de um ficheiro do storage.</summary>
    private static string PublicPath(string storagePath) => "uploads/" + storagePath.TrimStart('/');

    private static PodcastEpisodeDto ToDto(EpisodeRow e, PodcastProgress? p) => new(
        e.Id.ToString(), e.Title, e.Description, e.Language, e.Level, e.Series, e.Season, e.EpisodeNumber, e.DurationMs,
        PublicPath(e.AudioPath),
        e.SlowAudioPath is null ? null : PublicPath(e.SlowAudioPath),
        e.SlowTempo,
        p is null ? null : ToDto(p));

    private static PodcastProgressDto ToDto(PodcastProgress p) =>
        new(p.PositionMs, p.IsCompleted, p.CompletedAt, p.LastPlayedAt, p.PlayCount, p.IsFavorite);
}
