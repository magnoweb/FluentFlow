using FluentFlow.Core.Common;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FluentFlow.Api.Extensions;

public static class ControllerExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal user) =>
        Guid.Parse(user.FindFirstValue(ClaimTypes.NameIdentifier)!);

    public static IActionResult ToActionResult<T>(this Result<T> result) =>
        result.IsSuccess
            ? new OkObjectResult(result.Value)
            : new NotFoundObjectResult(new { error = result.Error });

    public static IActionResult ToActionResult(this Result result) =>
        result.IsSuccess
            ? new OkResult()
            : new BadRequestObjectResult(new { error = result.Error });
}