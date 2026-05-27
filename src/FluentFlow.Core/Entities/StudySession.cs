using FluentFlow.Core.Entities.Base;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Entities;

public class StudySession : BaseEntity
{
    public Guid DeckId { get; set; }
    public Guid UserId { get; set; }
    public StudyMode Mode { get; set; }
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public DateTime? EndedAt { get; set; }
    public int TotalCards { get; set; }
    public int ReviewedCards { get; set; }

    // Navigation
    public Deck Deck { get; set; } = null!;
    public ICollection<StudyReview> Reviews { get; set; } = new List<StudyReview>();
}