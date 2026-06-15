using Microsoft.AspNetCore.Authorization;

namespace FluentFlow.Api.Extensions;

public class AdminRequirement : IAuthorizationRequirement { }

public class AdminHandler : AuthorizationHandler<AdminRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context, AdminRequirement requirement)
    {
        var userType = context.User.FindFirst("userType")?.Value;

        if (userType == "Admin")
            context.Succeed(requirement);

        return Task.CompletedTask;
    }
}