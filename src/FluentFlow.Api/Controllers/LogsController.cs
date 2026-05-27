using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/logs")]
public class LogsController(ILogService logService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetPaged([FromQuery] LogFilterDto filter) =>
        Ok(await logService.GetPagedAsync(filter));

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var log = await logService.GetByIdAsync(id);
        return log is null ? NotFound() : Ok(log);
    }
}