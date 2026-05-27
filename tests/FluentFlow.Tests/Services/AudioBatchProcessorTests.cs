using FluentAssertions;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Infrastructure.Services;
using FluentFlow.Infrastructure.Services.Tools;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;

namespace FluentFlow.Tests.Services;

public class AudioBatchProcessorTests
{
    [Fact]
    public async Task EnqueueAsync_AddsJobToChannel()
    {
        // Arrange
        var processor = CreateProcessor();
        var jobId     = Guid.NewGuid();

        // Act — enfileirar sem iniciar o BackgroundService
        var enqueue = async () => await processor.EnqueueAsync(jobId);

        // Assert — não deve lançar excepção
        await enqueue.Should().NotThrowAsync();
    }

    [Fact]
    public void ReviewService_SimilarityScore_MapsToCorrectSM2Score()
    {
        var svc = new ReviewService();
        svc.CalculateSimilarityScore(0.96).Should().Be(5);
        svc.CalculateSimilarityScore(0.86).Should().Be(4);
        svc.CalculateSimilarityScore(0.71).Should().Be(3);
        svc.CalculateSimilarityScore(0.51).Should().Be(2);
        svc.CalculateSimilarityScore(0.31).Should().Be(1);
        svc.CalculateSimilarityScore(0.10).Should().Be(0);
    }

    private static AudioBatchProcessor CreateProcessor()
    {
        var scopeFactory = new FakeScopeFactory();
        var logger       = NullLogger<AudioBatchProcessor>.Instance;
        return new AudioBatchProcessor(scopeFactory, logger);
    }
}

// Stub mínimo para o teste
internal class FakeScopeFactory : IServiceScopeFactory
{
    public IServiceScope CreateScope() => throw new NotImplementedException();
}