using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

[Authorize(Policy = "AdminOnly")]
[ApiController]
[Route("api/admin")]
public class AdminController(IAdminService adminService) : ControllerBase
{
    [HttpGet("users")]
    public async Task<IActionResult> GetUsers([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] string? search = null) =>
        Ok(await adminService.GetUsersAsync(page, pageSize, search));

    [HttpGet("users/{id:guid}")]
    public async Task<IActionResult> GetUserDetail(Guid id)
    {
        var result = await adminService.GetUserDetailAsync(id);
        return result.IsSuccess ? Ok(result.Value) : NotFound(new { error = result.Error });
    }

    [HttpGet("access-logs")]
    public async Task<IActionResult> GetAccessLogs([FromQuery] AccessLogFilterDto filter) =>
        Ok(await adminService.GetAccessLogsAsync(filter));
}