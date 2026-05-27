using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace FluentFlow.Api.Hubs;

public class NameIdentifierUserIdProvider : IUserIdProvider
{
    public string? GetUserId(HubConnectionContext connection) =>
        connection.User.FindFirstValue(ClaimTypes.NameIdentifier);
}