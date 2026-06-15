namespace FluentFlow.Core.Entities;

public class AccessLog
{
    public long Id { get; set; }
    public Guid UserId { get; set; }
    public string Platform  { get; set; } = null!; // "Web", "Mobile", "Unknown"
    public string? UserAgent { get; set; }
    public string IpAddress { get; set; } = null!;
    public DateTime LoggedInAt { get; set; } = DateTime.UtcNow;
}