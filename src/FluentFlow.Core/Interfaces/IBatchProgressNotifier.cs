using FluentFlow.Core.DTOs;

namespace FluentFlow.Core.Interfaces;

public interface IBatchProgressNotifier
{
    Task NotifyAsync(Guid userId, BatchProgressDto progress);
}