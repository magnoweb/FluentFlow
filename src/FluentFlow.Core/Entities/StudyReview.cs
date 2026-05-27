using FluentFlow.Core.Entities.Base;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Entities;

public class StudyReview : BaseEntity
{
    public Guid SessionId { get; set; }
    public Guid CardId { get; set; }
    public StudyMode Mode { get; set; }
    public int Score { get; set; }              // 0–5 (SM-2)
    public double? SimilarityScore { get; set; } // Speaking: 0.0–1.0
    public string? TranscribedText { get; set; }
    public int PreviousInterval { get; set; }
    public int NewInterval { get; set; }
    public DateTime ReviewedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public StudySession Session { get; set; } = null!;
    public Card Card { get; set; } = null!;
}