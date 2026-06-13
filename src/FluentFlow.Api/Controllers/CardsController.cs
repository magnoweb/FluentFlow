using FluentFlow.Api.Extensions;
using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/decks/{deckId:guid}/cards")]
public class CardsController(ICardService cardService, IStorageService storage, ILogger<CardsController> logger) : ControllerBase
{
    private static readonly string[] AllowedExtensions = [".wav", ".mp3", ".m4a", ".ogg", ".flac"];
    
    [HttpGet]
    public async Task<IActionResult> GetAll(Guid deckId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var result = await cardService.GetByDeckAsync(deckId, User.GetUserId(), page, pageSize);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid deckId, Guid id) => (await cardService.GetByIdAsync(id, User.GetUserId())).ToActionResult();

    [HttpPost]
    public async Task<IActionResult> Create(Guid deckId, [FromBody] CreateCardDto dto)
    {
        var result = await cardService.CreateAsync(deckId, dto, User.GetUserId());
        if (!result.IsSuccess) return BadRequest(new { error = result.Error });
        return CreatedAtAction(nameof(GetById), new { deckId, id = result.Value!.Id }, result.Value);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid deckId, Guid id, [FromBody] UpdateCardDto dto) => (await cardService.UpdateAsync(id, dto, User.GetUserId())).ToActionResult();

    [HttpPost("recalculate-cefr")]
    public async Task<IActionResult> RecalculateCefr(Guid deckId, [FromServices] FluentFlowDbContext db)
    {
        var userId = User.GetUserId();

        var deck = await db.Decks
            .FirstOrDefaultAsync(d => d.Id == deckId
                                      && d.UserId == userId
                                      && d.IsActive);
        if (deck is null)
            return NotFound(new { error = "Deck não encontrado." });

        var cards = await db.Cards
            .Where(c => c.DeckId == deckId && c.IsActive)
            .ToListAsync();

        foreach (var card in cards)
            card.CefrLevel = CefrCalculator.Calculate(card.Front);

        await db.SaveChangesAsync();

        var distribution = cards
            .GroupBy(c => c.CefrLevel)
            .OrderBy(g => g.Key)
            .Select(g => new
            {
                level = g.Key?.ToString(),
                label = g.Key.HasValue
                    ? CefrCalculator.GetLabel(g.Key.Value) : "N/A",
                count = g.Count()
            });

        return Ok(new { updated = cards.Count, distribution });
    }
    
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid deckId, Guid id) => (await cardService.DeleteAsync(id, User.GetUserId())).ToActionResult();
    
    // ── Upload de áudio individual para um card ───────────────────────────────
    [HttpPost("{id:guid}/audio")]
    [RequestSizeLimit(50 * 1024 * 1024)] // 50 MB
    public async Task<IActionResult> UploadAudio(Guid deckId, Guid id, IFormFile file)
    {
        if (file is null || file.Length == 0)
            return BadRequest(new { error = LocalizationHelper.Get("Api.FileNotProvided")});

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!AllowedExtensions.Contains(ext))
            return BadRequest(new { error = string.Format(LocalizationHelper.Get("Api.ExtensionNotSupportedDetailed"), ext) });

        var userId = User.GetUserId();

        // Verificar que o card pertence ao utilizador
        var cardResult = await cardService.GetByIdAsync(id, userId);
        if (!cardResult.IsSuccess)
            return NotFound(new { error = cardResult.Error });

        try
        {
            await using var stream = file.OpenReadStream();
            var path = await storage.SaveAsync(stream, file.FileName, $"audio/{deckId}");

            // Actualizar o AudioPath do card
            var updateDto = new UpdateCardDto(
                cardResult.Value!.Front,
                cardResult.Value.Back,
                cardResult.Value.Pronunciation,
                AudioPath: path);

            var updateResult = await cardService.UpdateAsync(id, updateDto, userId);
            if (!updateResult.IsSuccess)
                return BadRequest(new { error = updateResult.Error });

            return Ok(new { audioPath = path, audioUrl = $"/uploads/{path}" });
        }
        catch (Exception ex)
        {
            using (Serilog.Context.LogContext.PushProperty("UserId", userId))
            using (Serilog.Context.LogContext.PushProperty("CardId", id))
            {
                logger.LogError(ex, "Falha no upload de áudio para o card {CardId}", id);
            }
            return StatusCode(500, new { error = LocalizationHelper.Get("Api.FileSaveError") });
        }
    }

    // ── Remover áudio de um card ──────────────────────────────────────────────
    [HttpDelete("{id:guid}/audio")]
    public async Task<IActionResult> DeleteAudio(Guid deckId, Guid id)
    {
        var userId = User.GetUserId();
        var cardResult = await cardService.GetByIdAsync(id, userId);
        if (!cardResult.IsSuccess)
            return NotFound(new { error = cardResult.Error });

        var card = cardResult.Value!;
        if (card.AudioPath is not null)
        {
            try { await storage.DeleteAsync(card.AudioPath); }
            catch (Exception ex)
            {
                logger.LogError(ex, $"Não foi possível apagar o ficheiro de áudio {card.AudioPath}");
            }
        }

        var updateDto    = new UpdateCardDto(card.Front, card.Back, card.Pronunciation, AudioPath: "");
        var updateResult = await cardService.UpdateAsync(id, updateDto, userId);
        return updateResult.IsSuccess ? NoContent() : BadRequest(new { error = updateResult.Error });
    }
}