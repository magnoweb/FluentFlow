using FluentFlow.Core.Entities.Base;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Entities;

public class Card : BaseEntity
{
    public Guid DeckId { get; set; }
    public string Front { get; set; } = null!;       // texto na língua estrangeira
    public string Back { get; set; } = null!;         // tradução / significado
    public string? Pronunciation { get; set; }
    public string? AudioPath { get; set; }            // URL ou path local

    // SM-2 — Listening
    public int    ListeningRepetitions { get; set; } = 0;
    public double ListeningEaseFactor { get; set; } = 2.5;
    public int    ListeningInterval { get; set; } = 0;
    public DateTime? ListeningNextReview { get; set; }

    // SM-2 — Speaking
    public int    SpeakingRepetitions { get; set; } = 0;
    public double SpeakingEaseFactor { get; set; } = 2.5;
    public int    SpeakingInterval { get; set; } = 0;
    public DateTime? SpeakingNextReview { get; set; }

    public bool IsActive { get; set; } = true;
    public CefrLevel? CefrLevel { get; set; }

    // Navigation
    public Deck Deck { get; set; } = null!;
    public ICollection<StudyReview> Reviews { get; set; } = new List<StudyReview>();
}