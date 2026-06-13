using FluentFlow.Api.Extensions;
using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/study")]
public class StudyController(IStudySchedulerService scheduler, IStudySessionService sessionService, ILogger<StudyController> logger) : ControllerBase
{
    [HttpGet("plan/{deckId:guid}")]
    public async Task<IActionResult> GetPlan(Guid deckId, [FromQuery] StudyMode mode = StudyMode.Listening) =>
        (await scheduler.GetPlanAsync(deckId, User.GetUserId(), mode)).ToActionResult();

    [HttpGet("dashboard/{deckId:guid}")]
    public async Task<IActionResult> GetDashboard(Guid deckId) =>
        (await sessionService.GetDashboardAsync(deckId, User.GetUserId())).ToActionResult();

    [HttpPost("start")]
    public async Task<IActionResult> Start([FromBody] StartSessionDto dto)
    {
        var result = await sessionService.StartAsync(dto, User.GetUserId());
        if (!result.IsSuccess) return BadRequest(new { error = result.Error });
        return Ok(new { sessionId = result.Value });
    }

    [HttpPost("review")]
    public async Task<IActionResult> SubmitReview([FromBody] SubmitReviewDto dto) =>
        (await sessionService.SubmitReviewAsync(dto, User.GetUserId())).ToActionResult();

    [HttpPost("end/{sessionId:guid}")]
    public async Task<IActionResult> End(Guid sessionId) =>
        (await sessionService.EndAsync(sessionId, User.GetUserId())).ToActionResult();
    
    [HttpPost("transcribe")]
    public async Task<IActionResult> Transcribe([FromBody] TranscribeRequestDto dto, [FromServices] ISpeechToTextService stt, [FromServices] IAudioConverterService converter)
    {
        if (string.IsNullOrWhiteSpace(dto.AudioBase64))
            return BadRequest(new { error = LocalizationHelper.Get("Api.AudioNotProvided") });

        if (string.IsNullOrWhiteSpace(dto.OriginalText))
            return BadRequest(new { error = LocalizationHelper.Get("Api.OriginalTextNotProvided") });

        var ext = string.IsNullOrWhiteSpace(dto.Extension) ? ".webm" : dto.Extension;
        var tempInput = Path.Combine(Path.GetTempPath(), $"rec_{Guid.NewGuid():N}{ext}");
        var tempWav   = string.Empty;

        try
        {
            // 1. Descodificar base64 → ficheiro temporário
            var bytes = Convert.FromBase64String(dto.AudioBase64);
            await System.IO.File.WriteAllBytesAsync(tempInput, bytes);

            // 2. Converter para WAV PCM 16kHz mono (requisito do Whisper)
            tempWav = await converter.ConvertToWavAsync(tempInput);

            // 3. Transcrever com Whisper
            var transcribed = await stt.TranscribeAsync(tempWav, dto.Language);

            // 4. Calcular similaridade com Levenshtein
            var similarity = TextSimilarity.Calculate(transcribed, dto.OriginalText);

            return Ok(new TranscribeResultDto(transcribed, similarity));
        }
        catch (Exception ex)
        {
            var userId = User.GetUserId();
            // Registo estruturado — UserId e Language ficam indexados na coluna Properties
            using (Serilog.Context.LogContext.PushProperty("UserId", userId))
            using (Serilog.Context.LogContext.PushProperty("Language", dto.Language))
            {
                logger.LogError(ex,
                    "Transcription failure for the user {UserId}. " +
                    "Language: {Language}. Original text: {OriginalText}",
                    userId, dto.Language, dto.OriginalText);
            }
            
            return StatusCode(500, new { error = LocalizationHelper.Get("Api.TranscriptionError") });
        }
        finally
        {
            // Garantir limpeza dos ficheiros temporários
            if (System.IO.File.Exists(tempInput)) System.IO.File.Delete(tempInput);
            if (!string.IsNullOrEmpty(tempWav) && System.IO.File.Exists(tempWav))
                System.IO.File.Delete(tempWav);
        }
    }
    
    [HttpGet("sessions")]
    public async Task<IActionResult> GetSessions([FromQuery] Guid? deckId = null, [FromQuery] string? mode = null, [FromQuery] int page = 1, [FromQuery] int pageSize = 20) =>
        Ok(await sessionService.GetSessionsAsync(User.GetUserId(), deckId, mode, page, pageSize));

    [HttpGet("sessions/{sessionId:guid}")]
    public async Task<IActionResult> GetSessionDetail(Guid sessionId) =>
        (await sessionService.GetSessionDetailAsync(sessionId, User.GetUserId())).ToActionResult();
}