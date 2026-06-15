namespace FluentFlow.Core.DTOs;

public record AccessLogDto(
    long Id,
    Guid UserId,
    string UserName,
    string UserEmail,
    string Platform,
    string IpAddress,
    string? UserAgent,
    DateTime LoggedInAt
);

public record AccessLogFilterDto
{
    public Guid? UserId { get; set; }
    public string? Platform { get; set; }
    public DateTime? DateFrom { get; set; }
    public DateTime? DateTo { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 50;
}