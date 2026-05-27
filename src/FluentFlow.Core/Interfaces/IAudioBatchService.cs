using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface IAudioBatchService
{
    Task<Result<Guid>> UploadAsync(Guid deckId, Guid userId, IEnumerable<(Stream Content, string FileName)> files);
    Task<Result<BatchJobDto>> GetJobStatusAsync(Guid jobId, Guid userId);
    Task<Result<IReadOnlyList<BatchJobDto>>> GetJobsByDeckAsync(Guid deckId, Guid userId);
}