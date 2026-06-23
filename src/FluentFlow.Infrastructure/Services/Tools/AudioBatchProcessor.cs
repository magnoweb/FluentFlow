using System.Threading.Channels;
using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Polly;
using Polly.CircuitBreaker;
using Polly.Retry;

namespace FluentFlow.Infrastructure.Services.Tools;

public class AudioBatchProcessor : BackgroundService
{
    private readonly Channel<Guid> _queue;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<AudioBatchProcessor> _logger;
    private readonly AsyncRetryPolicy _retryPolicy;
    private readonly AsyncCircuitBreakerPolicy _circuitBreaker;
    private const int MaxConcurrency = 2;

    public AudioBatchProcessor(IServiceScopeFactory scopeFactory, ILogger<AudioBatchProcessor> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;

        _queue = Channel.CreateBounded<Guid>(new BoundedChannelOptions(50)
        {
            FullMode = BoundedChannelFullMode.Wait,
            SingleReader = false,
            SingleWriter = false,
        });

        _retryPolicy = Policy
            .Handle<Exception>(ex => ex is not OperationCanceledException)
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)),
                onRetry: (ex, delay, attempt, _) =>
                    logger.LogWarning(ex, $"Retry {attempt}/3 after {delay.TotalSeconds}s"));

        _circuitBreaker = Policy
            .Handle<Exception>()
            .CircuitBreakerAsync(
                exceptionsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromMinutes(1),
                onBreak: (ex, d) => logger.LogError(ex, $"Circuit breaker aberto por {d}", d),
                onReset: () => logger.LogInformation("Circuit breaker fechado."),
                onHalfOpen: () => logger.LogInformation("Circuit breaker em half-open."));
    }

    public async ValueTask EnqueueAsync(Guid jobId, CancellationToken ct = default)
    {
        await _queue.Writer.WriteAsync(jobId, ct);
        _logger.LogInformation($"Job {jobId} queueded.");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("AudioBatchProcessor started.");
        await ResumeInterruptedJobsAsync(stoppingToken);

        var semaphore = new SemaphoreSlim(MaxConcurrency);

        await foreach (var jobId in _queue.Reader.ReadAllAsync(stoppingToken))
        {
            await semaphore.WaitAsync(stoppingToken);
            _ = Task.Run(async () =>
            {
                try { await ProcessJobAsync(jobId, stoppingToken); }
                finally { semaphore.Release(); }
            }, stoppingToken);
        }
    }

    private async Task ResumeInterruptedJobsAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FluentFlowDbContext>();
        
        // ── Itens que ficaram "Processing" quando o processo morreu ──────────────
        // Não confiar neles — provavelmente causaram o crash anterior
        var orphanedItems = await db.AudioBatchItems
            .Where(i => i.Status == JobStatus.Processing)
            .ToListAsync(ct);

        foreach (var item in orphanedItems)
        {
            item.RetryCount++;
            item.ErrorMessage = "Process terminated unexpectedly during transcription (possible memory limit).";
            item.Status = item.RetryCount >= 3 ? JobStatus.Failed : JobStatus.Pending;

            _logger.LogWarning($"Item {item.Id} ({item.FileName}) was orphaned in Processing state — marked as {item.Status} (retry {item.RetryCount}/3)");
        }

        if (orphanedItems.Count > 0)
            await db.SaveChangesAsync(ct);

        var interrupted = await db.AudioBatchJobs
            .Where(j => j.Status == JobStatus.Pending || j.Status == JobStatus.Processing)
            .Select(j => j.Id)
            .ToListAsync(ct);

        foreach (var id in interrupted)
        {
            _logger.LogInformation($"Resuming interrupted job: {id}");
            await _queue.Writer.WriteAsync(id, ct);
        }
    }

    private async Task ProcessJobAsync(Guid jobId, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FluentFlowDbContext>();
        var stt = scope.ServiceProvider.GetRequiredService<ISpeechToTextService>();
        var transl = scope.ServiceProvider.GetRequiredService<ITranslationService>();
        var notifier = scope.ServiceProvider.GetRequiredService<IBatchProgressNotifier>();
        var converter = scope.ServiceProvider.GetRequiredService<IAudioConverterService>();

        var job = await db.AudioBatchJobs
            .Include(j => j.Items)
            .FirstOrDefaultAsync(j => j.Id == jobId, ct);

        if (job is null)
        {
            _logger.LogWarning($"Job {jobId} not found.");
            return;
        }

        job.Status = JobStatus.Processing;
        job.StartedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);

        var deck = await db.Decks.FindAsync([job.DeckId], ct);

        foreach (var item in job.Items.Where(i => i.Status == JobStatus.Pending))
        {
            if (ct.IsCancellationRequested) break;

            string? wavPath = null;
            try
            {
                wavPath = await converter.ConvertToWavAsync(item.FilePath);
                await ProcessItemAsync(item, wavPath, job, deck!, db, stt, transl, notifier, ct);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Item conversion failed {item.Id}.");
                MarkItemFailed(item, job, $"Conversion error: {ex.Message}");
                await db.SaveChangesAsync(ct);
                await NotifyProgressAsync(notifier, job);
            }
            finally
            {
                // Apagar sempre o ficheiro temporário
                if (wavPath is not null && File.Exists(wavPath))
                {
                    File.Delete(wavPath);
                    _logger.LogDebug($"Temporary file removed: {wavPath}");
                }
            }
        }

        job.Status = job.FailedFiles == job.TotalFiles 
            ? JobStatus.Failed
            : job.FailedFiles > 0               
                ? JobStatus.PartialSuccess 
                : JobStatus.Completed;
        job.CompletedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        await NotifyProgressAsync(notifier, job);

        _logger.LogInformation($"Job {job.Id} completed: {job.Status} ({job.ProcessedFiles}/{job.TotalFiles})");
    }

    private async Task ProcessItemAsync(
        AudioBatchItem item,
        string wavPath,
        AudioBatchJob job,
        Deck deck,
        FluentFlowDbContext db,
        ISpeechToTextService stt,
        ITranslationService transl,
        IBatchProgressNotifier notifier,
        CancellationToken ct)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var phonetic = scope.ServiceProvider.GetRequiredService<IPhoneticService>();
            
            item.Status = JobStatus.Processing;
            await db.SaveChangesAsync(ct);

            // 1. Transcrever
            var transcribed = await _circuitBreaker.ExecuteAsync(() =>
                _retryPolicy.ExecuteAsync(() => stt.TranscribeAsync(wavPath, deck.Language)));

            item.TranscribedText = transcribed;

            // 2. Traduzir
            var translated = await _circuitBreaker.ExecuteAsync(() =>
                _retryPolicy.ExecuteAsync(() => transl.TranslateAsync(transcribed, deck.Language, deck.NativeLanguage)));

            item.TranslatedText = translated;
            
            // 3. Calcular CEFR
            var cefrLevel = CefrCalculator.Calculate(transcribed);
            
            // 4. Gerar pronúncia fonética (Lytspel)
            // Só aplicar se o deck é em inglês — PhoneticFlow suporta apenas EN
            var pronunciation = deck.Language.StartsWith("en", StringComparison.OrdinalIgnoreCase)
                ? phonetic.Convert(transcribed, deck.Language)
                : null;

            // 5. Criar card
            db.Cards.Add(new Card { DeckId = deck.Id, Front = transcribed, Back = translated, AudioPath = item.FilePath, CefrLevel = cefrLevel, Pronunciation = pronunciation});

            item.Status = JobStatus.Completed;
            job.ProcessedFiles++;
        }
        catch (BrokenCircuitException ex)
        {
            _logger.LogError(ex, $"Circuit breaker open — item {item.Id} failed.");
            MarkItemFailed(item, job, "Service temporarily unavailable.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error processing item {item.Id}.");
            MarkItemFailed(item, job, ex.Message);
        }

        await db.SaveChangesAsync(ct);
        await NotifyProgressAsync(notifier, job);
    }

    private static void MarkItemFailed(AudioBatchItem item, AudioBatchJob job, string error)
    {
        item.RetryCount++;
        item.ErrorMessage = error;
        item.Status = item.RetryCount >= 3 ? JobStatus.Failed : JobStatus.Pending;
        if (item.Status == JobStatus.Failed) job.FailedFiles++;
    }

    private static async Task NotifyProgressAsync(IBatchProgressNotifier notifier, AudioBatchJob job)
    {
        var progress = new BatchProgressDto(
            job.Id,
            job.TotalFiles,
            job.ProcessedFiles,
            job.FailedFiles,
            job.Status.ToString(),
            job.Items.FirstOrDefault(i => i.Status == JobStatus.Processing)?.FileName);

        await notifier.NotifyAsync(job.UserId, progress);
    }
}