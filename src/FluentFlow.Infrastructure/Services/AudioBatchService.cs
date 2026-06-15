using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using FluentFlow.Infrastructure.Services.Tools;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FluentFlow.Infrastructure.Services;

public class AudioBatchService(
    FluentFlowDbContext db,
    IStorageService storage,
    AudioBatchProcessor processor,
    ILogger<AudioBatchService> logger) : IAudioBatchService
{
    private static readonly string[] AllowedExtensions = [".wav", ".mp3", ".m4a", ".ogg", ".flac"];

    public async Task<Result<Guid>> UploadAsync(Guid deckId, Guid userId, IEnumerable<(Stream Content, string FileName)> files)
    {
        var deck = await db.Decks.FirstOrDefaultAsync(d => d.Id == deckId && d.UserId == userId && d.IsActive);

        if (deck is null)
        {
            logger.LogWarning($"Upload rejected — deck {deckId} not found for user {userId}");
            return Result<Guid>.Failure(LocalizationHelper.Get("Api.DeckNotFound"));
        }

        var fileList = files.ToList();

        if (fileList.Count == 0)
            return Result<Guid>.Failure(LocalizationHelper.Get("Api.NoFilesUploaded"));

        var invalid = fileList
            .Where(f => !AllowedExtensions.Contains(Path.GetExtension(f.FileName).ToLowerInvariant()))
            .Select(f => f.FileName)
            .ToList();

        if (invalid.Count > 0)
        {
            logger.LogWarning("Upload rejected — invalid extensions: {Files} (UserId: {UserId})", string.Join(", ", invalid), userId);
            return Result<Guid>.Failure(string.Format(LocalizationHelper.Get("Api.ExtensionNotSupportedMultiple"), string.Join(", ", invalid)));
        }

        var job = new AudioBatchJob
        {
            DeckId = deckId,
            UserId = userId,
            TotalFiles = fileList.Count,
            Status = JobStatus.Pending,
        };
        db.AudioBatchJobs.Add(job);

        try
        {
            foreach (var (content, fileName) in fileList)
            {
                var path = await storage.SaveAsync(content, fileName, $"audio/{deckId}");
                job.Items.Add(new AudioBatchItem
                {
                    BatchJobId = job.Id,
                    FileName = fileName,
                    FilePath = path,
                    Status = JobStatus.Pending,
                });
            }

            await db.SaveChangesAsync();
            await processor.EnqueueAsync(job.Id);

            logger.LogInformation($"Job {job.Id} created with {job.TotalFiles} file(s) for deck {deckId}");

            return Result<Guid>.Success(job.Id);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to create upload job for the deck {DeckId} " +
                                "from user {UserId}. Files: {FileNames}", deckId, userId, string.Join(", ", fileList.Select(f => f.FileName)));

            return Result<Guid>.Failure(LocalizationHelper.Get("Api.UploadProcessingError"));
        }
    }

    public async Task<Result<BatchJobDto>> GetJobStatusAsync(Guid jobId, Guid userId)
    {
        var job = await db.AudioBatchJobs.FirstOrDefaultAsync(j => j.Id == jobId && j.UserId == userId);

        if (job is null)
        {
            logger.LogWarning($"Job {jobId} not found for the user {userId}");
            return Result<BatchJobDto>.Failure(LocalizationHelper.Get("Api.JobNotFoundDetailed"));
        }

        return Result<BatchJobDto>.Success(ToDto(job));
    }

    public async Task<Result<IReadOnlyList<BatchJobDto>>> GetJobsByDeckAsync(
        Guid deckId, Guid userId)
    {
        var jobs = await db.AudioBatchJobs
            .Where(j => j.DeckId == deckId && j.UserId == userId)
            .OrderByDescending(j => j.CreatedAt)
            .ToListAsync();

        return Result<IReadOnlyList<BatchJobDto>>.Success(
            jobs.Select(ToDto).ToList());
    }

    private static BatchJobDto ToDto(AudioBatchJob j) => new(
        j.Id, j.Status.ToString(), j.TotalFiles,
        j.ProcessedFiles, j.FailedFiles,
        j.StartedAt, j.CompletedAt);
}