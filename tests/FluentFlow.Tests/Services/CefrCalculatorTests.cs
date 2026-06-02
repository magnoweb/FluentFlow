using FluentAssertions;
using FluentFlow.Core.Common;
using FluentFlow.Core.Enums;

namespace FluentFlow.Tests;

public class CefrCalculatorTests
{
    [Theory]
    [InlineData("Hi",                          CefrLevel.A1)]
    [InlineData("Hello, how are you?",         CefrLevel.A1)]
    [InlineData("I go to school every day.",   CefrLevel.A1)]
    [InlineData("She is reading a book.",      CefrLevel.A2)]
    [InlineData("I would like to order food.", CefrLevel.A2)]
    [InlineData("He has been working here for two years.", CefrLevel.B1)]
    [InlineData("The government announced new environmental policies.", CefrLevel.B2)]
    [InlineData("The legislation was consequently amended.", CefrLevel.C1)]
    [InlineData("Notwithstanding the aforementioned constitutional implications, the judiciary has hitherto refrained from intervening.", CefrLevel.C2)]
    public void Calculate_ReturnsExpectedLevel(string text, CefrLevel expected)
    {
        var result = CefrCalculator.Calculate(text);
        result.Should().Be(expected);
    }

    [Fact]
    public void Calculate_EmptyText_ReturnsA1()
    {
        CefrCalculator.Calculate("").Should().Be(CefrLevel.A1);
        CefrCalculator.Calculate("   ").Should().Be(CefrLevel.A1);
    }

    [Fact]
    public void GetLabel_ReturnsCorrectLabels()
    {
        CefrCalculator.GetLabel(CefrLevel.A1).Should().Be("Iniciante");
        CefrCalculator.GetLabel(CefrLevel.C2).Should().Be("Proficiente");
    }

    [Fact]
    public void Score_IncreasesWithComplexity()
    {
        var simple  = CefrCalculator.ComputeScore("I eat food.");
        var complex = CefrCalculator.ComputeScore(
            "The environmental implications were consequently disregarded.");

        complex.Should().BeGreaterThan(simple);
    }
}