using FluentFlow.Api.Extensions;
using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/decks")]
public class DecksController(IDeckService deckService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var result = await deckService.GetAllAsync(User.GetUserId(), page, pageSize);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id) =>
        (await deckService.GetByIdAsync(id, User.GetUserId())).ToActionResult();

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDeckDto dto)
    {
        var result = await deckService.CreateAsync(dto, User.GetUserId());
        if (!result.IsSuccess) return BadRequest(new { error = result.Error });
        return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id }, result.Value);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateDeckDto dto) =>
        (await deckService.UpdateAsync(id, dto, User.GetUserId())).ToActionResult();

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id) =>
        (await deckService.DeleteAsync(id, User.GetUserId())).ToActionResult();
}