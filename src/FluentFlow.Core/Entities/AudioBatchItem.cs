using FluentFlow.Core.Entities.Base;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Entities;

public class AudioBatchItem : BaseEntity
{
    public Guid BatchJobId { get; set; }
    public string FileName { get; set; } = null!;
    public string FilePath { get; set; } = null!;
    public JobStatus Status { get; set; } = JobStatus.Pending;
    public string? TranscribedText { get; set; }
    public string? TranslatedText { get; set; }
    public string? ErrorMessage { get; set; }
    public int RetryCount { get; set; } = 0;

    // Navigation
    public AudioBatchJob BatchJob { get; set; } = null!;
}