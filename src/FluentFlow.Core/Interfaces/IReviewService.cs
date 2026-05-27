using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;

namespace FluentFlow.Core.Interfaces;

public interface IReviewService
{
    Card ApplySM2(Card card, StudyMode mode, int score);
    int CalculateSimilarityScore(double similarityRatio); // 0.0–1.0 → 0–5
}