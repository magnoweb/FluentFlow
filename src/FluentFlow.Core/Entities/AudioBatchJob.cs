using FluentFlow.Core.Entities.Base;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Entities;

public class AudioBatchJob : BaseEntity
{
    public Guid DeckId { get; set; }
    public Guid UserId { get; set; }
    public JobStatus Status { get; set; } = JobStatus.Pending;
    public int TotalFiles { get; set; }
    public int ProcessedFiles { get; set; }
    public int FailedFiles { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    // Navigation
    public Deck Deck { get; set; } = null!;
    public ICollection<AudioBatchItem> Items { get; set; } = new List<AudioBatchItem>();
}