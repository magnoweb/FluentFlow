using FluentFlow.Core.Entities.Base;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Entities;

public class ReviewHistory : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid DeckId { get; set; }
    public DateTime Date { get; set; }
    public StudyMode Mode { get; set; }
    public int CardsReviewed { get; set; }
    public int CardsNew { get; set; }
    public double AverageScore { get; set; }
}