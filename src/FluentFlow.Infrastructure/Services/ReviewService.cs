using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;

namespace FluentFlow.Infrastructure.Services;

public class ReviewService : IReviewService
{
    // SM-2 algorithm
    // Score: 0=blackout, 1=wrong, 2=wrong+easy, 3=correct+hard, 4=correct, 5=perfect
    public Card ApplySM2(Card card, StudyMode mode, int score)
    {
        if (score < 0 || score > 5)
            throw new ArgumentOutOfRangeException(nameof(score), "Score must be between 0 and 5.");

        if (mode == StudyMode.Listening)
            ApplyToListening(card, score);
        else
            ApplyToSpeaking(card, score);

        return card;
    }

    private static void ApplyToListening(Card card, int score)
    {
        var (reps, ef, interval) = ComputeSM2(
            card.ListeningRepetitions,
            card.ListeningEaseFactor,
            card.ListeningInterval,
            score);

        card.ListeningRepetitions = reps;
        card.ListeningEaseFactor  = ef;
        card.ListeningInterval    = interval;
        card.ListeningNextReview  = DateTime.UtcNow.AddDays(interval);
    }

    private static void ApplyToSpeaking(Card card, int score)
    {
        var (reps, ef, interval) = ComputeSM2(
            card.SpeakingRepetitions,
            card.SpeakingEaseFactor,
            card.SpeakingInterval,
            score);

        card.SpeakingRepetitions = reps;
        card.SpeakingEaseFactor  = ef;
        card.SpeakingInterval    = interval;
        card.SpeakingNextReview  = DateTime.UtcNow.AddDays(interval);
    }

    private static (int reps, double ef, int interval) ComputeSM2(
        int reps, double ef, int interval, int score)
    {
        if (score < 3)
        {
            // Resposta incorrecta — reinicia repetições
            reps     = 0;
            interval = 1;
        }
        else
        {
            interval = reps switch
            {
                0 => 1,
                1 => 6,
                _ => (int)Math.Round(interval * ef)
            };
            reps++;
        }

        // Actualizar ease factor
        ef = Math.Max(1.3, ef + (0.1 - (5 - score) * (0.08 + (5 - score) * 0.02)));

        return (reps, ef, interval);
    }

    // Converte similaridade de texto (0.0–1.0) num score SM-2 (0–5)
    public int CalculateSimilarityScore(double similarityRatio) => similarityRatio switch
    {
        >= 0.95 => 5,
        >= 0.85 => 4,
        >= 0.70 => 3,
        >= 0.50 => 2,
        >= 0.30 => 1,
        _       => 0
    };
}