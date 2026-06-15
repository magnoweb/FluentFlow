using FluentFlow.Api.Extensions;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/batch")]
public class AudioBatchController(IAudioBatchService batchService) : ControllerBase
{
    [HttpPost("upload/{deckId:guid}")]
    [RequestSizeLimit(50 * 1024 * 1024)] // 50 MB
    public async Task<IActionResult> Upload(Guid deckId, IList<IFormFile> files)
    {
        var userId = User.GetUserId();
        var streams = files.Select(f => (f.OpenReadStream(), f.FileName)).ToList();
        var result = await batchService.UploadAsync(deckId, userId, streams);

        // Garantir que os streams são fechados
        foreach (var (stream, _) in streams)
            await stream.DisposeAsync();

        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });

        return Accepted(new { jobId = result.Value });
    }

    [HttpGet("jobs/{jobId:guid}/status")]
    public async Task<IActionResult> GetJobStatus(Guid jobId)
    {
        var result = await batchService.GetJobStatusAsync(jobId, User.GetUserId());
        return result.IsSuccess
            ? Ok(result.Value)
            : NotFound(new { error = result.Error });
    }

    [HttpGet("jobs/deck/{deckId:guid}")]
    public async Task<IActionResult> GetJobsByDeck(Guid deckId)
    {
        var result = await batchService.GetJobsByDeckAsync(deckId, User.GetUserId());
        return result.IsSuccess
            ? Ok(result.Value)
            : BadRequest(new { error = result.Error });
    }
}