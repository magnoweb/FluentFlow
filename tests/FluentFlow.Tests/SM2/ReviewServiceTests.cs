using FluentAssertions;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Infrastructure.Services;

namespace FluentFlow.Tests.SM2;

public class ReviewServiceTests
{
    private readonly ReviewService _sut = new();

    private static Card NewCard() => new()
    {
        Id = Guid.NewGuid(), DeckId = Guid.NewGuid(),
        Front = "Test", Back = "Teste",
        ListeningEaseFactor = 2.5, SpeakingEaseFactor = 2.5
    };

    [Theory]
    [InlineData(StudyMode.Listening)]
    [InlineData(StudyMode.Speaking)]
    public void FirstCorrectReview_SetsInterval1(StudyMode mode)
    {
        var card = NewCard();
        _sut.ApplySM2(card, mode, score: 4);

        GetInterval(card, mode).Should().Be(1);
        GetReps(card, mode).Should().Be(1);
    }

    [Theory]
    [InlineData(StudyMode.Listening)]
    [InlineData(StudyMode.Speaking)]
    public void SecondCorrectReview_SetsInterval6(StudyMode mode)
    {
        var card = NewCard();
        _sut.ApplySM2(card, mode, score: 4);
        _sut.ApplySM2(card, mode, score: 4);

        GetInterval(card, mode).Should().Be(6);
        GetReps(card, mode).Should().Be(2);
    }

    [Theory]
    [InlineData(StudyMode.Listening)]
    [InlineData(StudyMode.Speaking)]
    public void WrongAnswer_ResetsRepetitions(StudyMode mode)
    {
        var card = NewCard();
        _sut.ApplySM2(card, mode, score: 5);
        _sut.ApplySM2(card, mode, score: 5);
        _sut.ApplySM2(card, mode, score: 0); // errou

        GetReps(card, mode).Should().Be(0);
        GetInterval(card, mode).Should().Be(1);
    }

    [Fact]
    public void EaseFactor_NeverGoesBelowMin()
    {
        var card = NewCard();
        for (int i = 0; i < 20; i++)
            _sut.ApplySM2(card, StudyMode.Listening, score: 0);

        card.ListeningEaseFactor.Should().BeGreaterThanOrEqualTo(1.3);
    }

    [Fact]
    public void PerfectScore_IncreasesEaseFactor()
    {
        var card = NewCard();
        _sut.ApplySM2(card, StudyMode.Listening, score: 5);

        card.ListeningEaseFactor.Should().BeGreaterThan(2.5);
    }

    [Fact]
    public void ListeningAndSpeaking_AreIndependent()
    {
        var card = NewCard();
        _sut.ApplySM2(card, StudyMode.Listening, score: 5);
        _sut.ApplySM2(card, StudyMode.Listening, score: 5);

        // Speaking não foi tocado
        card.SpeakingRepetitions.Should().Be(0);
        card.SpeakingInterval.Should().Be(0);
    }

    [Theory]
    [InlineData(0.97, 5)]
    [InlineData(0.88, 4)]
    [InlineData(0.72, 3)]
    [InlineData(0.55, 2)]
    [InlineData(0.35, 1)]
    [InlineData(0.10, 0)]
    public void SimilarityScore_MapsCorrectly(double ratio, int expected)
    {
        _sut.CalculateSimilarityScore(ratio).Should().Be(expected);
    }

    [Fact]
    public void InvalidScore_ThrowsException()
    {
        var card = NewCard();
        var act = () => _sut.ApplySM2(card, StudyMode.Listening, score: 6);
        act.Should().Throw<ArgumentOutOfRangeException>();
    }

    private static int GetInterval(Card c, StudyMode m) =>
        m == StudyMode.Listening ? c.ListeningInterval : c.SpeakingInterval;

    private static int GetReps(Card c, StudyMode m) =>
        m == StudyMode.Listening ? c.ListeningRepetitions : c.SpeakingRepetitions;
}