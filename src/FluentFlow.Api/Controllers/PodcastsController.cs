using FluentFlow.Api.Extensions;
using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/podcasts")]
public class PodcastsController(IPodcastService podcastService) : ControllerBase
{
    private const long MaxUploadBytes = 200L * 1024 * 1024; // 200 MB por episódio (normal + lento)

    /// <summary>Biblioteca do utilizador agrupada por série (episódios sem série ficam em "geral") + continuar a ouvir.</summary>
    [HttpGet]
    public async Task<IActionResult> GetLibrary() =>
        Ok(await podcastService.GetLibraryAsync(User.GetUserId()));

    /// <summary>Episódio com transcrição sincronizada.</summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetEpisode(Guid id) =>
        (await podcastService.GetEpisodeAsync(id, User.GetUserId())).ToActionResult();

    /// <summary>
    /// Envia um episódio gerado pelo PodcastGenerator: transcrição ({id}.json), áudio ({id}.mp3)
    /// e, opcionalmente, a versão lenta ({id}.slow.mp3). Se já existir um episódio com o mesmo id, é substituído.
    /// </summary>
    [HttpPost]
    [RequestSizeLimit(MaxUploadBytes)]
    [RequestFormLimits(MultipartBodyLengthLimit = MaxUploadBytes)]
    public async Task<IActionResult> Upload(IFormFile? transcript, IFormFile? audio, IFormFile? slowAudio)
    {
        if (transcript is null || transcript.Length == 0 || audio is null || audio.Length == 0)
            return BadRequest(new { error = LocalizationHelper.Get("Api.PodcastFilesRequired") });

        await using var transcriptStream = transcript.OpenReadStream();
        await using var audioStream = audio.OpenReadStream();
        await using var slowStream = slowAudio is { Length: > 0 } ? slowAudio.OpenReadStream() : null;

        var result = await podcastService.UploadAsync(
            transcriptStream,
            new PodcastUploadFile(audioStream, audio.FileName),
            slowStream is null ? null : new PodcastUploadFile(slowStream, slowAudio!.FileName),
            User.GetUserId());

        return result.IsSuccess ? Ok(result.Value) : BadRequest(new { error = result.Error });
    }

    /// <summary>Elimina o episódio (ficheiros e progresso incluídos).</summary>
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var result = await podcastService.DeleteAsync(id, User.GetUserId());
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }

    /// <summary>Grava a posição de reprodução (e marca como ouvido no fim).</summary>
    [HttpPut("{id:guid}/progress")]
    public async Task<IActionResult> UpdateProgress(Guid id, [FromBody] UpdatePodcastProgressDto dto) =>
        (await podcastService.UpdateProgressAsync(id, dto, User.GetUserId())).ToActionResult();

    /// <summary>Marca como não ouvido e volta ao início.</summary>
    [HttpDelete("{id:guid}/progress")]
    public async Task<IActionResult> ResetProgress(Guid id) =>
        (await podcastService.ResetProgressAsync(id, User.GetUserId())).ToActionResult();

    [HttpPut("{id:guid}/favorite")]
    public async Task<IActionResult> SetFavorite(Guid id, [FromBody] SetPodcastFavoriteDto dto) =>
        (await podcastService.SetFavoriteAsync(id, dto.IsFavorite, User.GetUserId())).ToActionResult();
}
