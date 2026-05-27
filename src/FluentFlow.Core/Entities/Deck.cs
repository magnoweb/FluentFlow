using FluentFlow.Core.Entities.Base;

namespace FluentFlow.Core.Entities;

public class Deck : BaseEntity
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;       // ex: "en", "fr"
    public string NativeLanguage { get; set; } = null!; // ex: "pt"
    public int MaxNewCardsPerDay { get; set; } = 20;
    public int MaxReviewsPerDay { get; set; } = 100;
    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<Card> Cards { get; set; } = new List<Card>();
    public ICollection<StudySession> Sessions { get; set; } = new List<StudySession>();
    public ICollection<AudioBatchJob> BatchJobs { get; set; } = new List<AudioBatchJob>();
}