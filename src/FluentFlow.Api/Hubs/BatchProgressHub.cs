using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace FluentFlow.Api.Hubs;

[Authorize]
public class BatchProgressHub : Hub
{
    // Cliente entra no seu grupo pessoal ao conectar
    public override async Task OnConnectedAsync()
    {
        var userId = Context.UserIdentifier!;
        await Groups.AddToGroupAsync(Context.ConnectionId, $"user-{userId}");
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.UserIdentifier!;
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user-{userId}");
        await base.OnDisconnectedAsync(exception);
    }
}