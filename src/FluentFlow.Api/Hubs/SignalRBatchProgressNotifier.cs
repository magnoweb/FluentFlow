using FluentFlow.Core.DTOs;
using FluentFlow.Core.Interfaces;
using Microsoft.AspNetCore.SignalR;

namespace FluentFlow.Api.Hubs;

public class SignalRBatchProgressNotifier(
    IHubContext<BatchProgressHub> hubContext) : IBatchProgressNotifier
{
    public async Task NotifyAsync(Guid userId, BatchProgressDto progress) =>
        await hubContext.Clients
            .Group($"user-{userId}")
            .SendAsync("BatchProgress", progress);
}