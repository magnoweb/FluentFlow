namespace FluentFlow.Core.DTOs;

public record BatchJobDto(
    Guid   Id,
    string Status,
    int    TotalFiles,
    int    ProcessedFiles,
    int    FailedFiles,
    DateTime? StartedAt,
    DateTime? CompletedAt
);