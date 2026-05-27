namespace FluentFlow.Core.DTOs;

public record BatchProgressDto(
    Guid   JobId,
    int    Total,
    int    Processed,
    int    Failed,
    string Status,        // Pending | Processing | Completed | Failed
    string? CurrentFile
);

public record BatchItemResultDto(
    Guid   ItemId,
    string FileName,
    bool   Success,
    string? TranscribedText,
    string? TranslatedText,
    string? ErrorMessage
);