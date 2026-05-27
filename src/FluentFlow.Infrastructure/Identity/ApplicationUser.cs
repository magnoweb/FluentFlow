using FluentFlow.Core.Enums;
using FluentFlow.Core.Entities;
using Microsoft.AspNetCore.Identity;

namespace FluentFlow.Infrastructure.Identity;

public class ApplicationUser : IdentityUser<Guid>
{
    public UserType UserType { get; set; } = UserType.Standard;
    public string Name { get; set; } = null!;
    public bool IsEnabled { get; set; } = true;
    public string? ProfileImageUrl { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<Deck> Decks { get; set; } = new List<Deck>();
    public ICollection<StudySession> StudySessions { get; set; } = new List<StudySession>();
    public ICollection<ReviewHistory> ReviewHistories { get; set; } = new List<ReviewHistory>();
    public ICollection<AudioBatchJob> AudioBatchJobs { get; set; } = new List<AudioBatchJob>();
}