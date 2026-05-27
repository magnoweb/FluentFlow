namespace FluentFlow.Core.DTOs;

public record LogDto(
    int      Id,
    string?  Level,
    string?  Message,
    DateTimeOffset TimeStamp,
    bool     HasException,
    Guid?    UserId,
    Guid?    CardId
);

public record LogDetailDto(
    int      Id,
    string?  Level,
    string?  Message,
    string?  MessageTemplate,
    DateTimeOffset TimeStamp,
    string?  Exception,
    string?  Properties,
    string?  LogEvent,
    Guid?    UserId,
    Guid?    CardId
);

public record LogFilterDto
{
    public string? Level { get; set; }
    public string?  Search { get; set; }
    public DateTime? DateFrom { get; set; }
    public DateTime? DateTo { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 50;
}