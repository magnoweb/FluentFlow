using FluentFlow.Core.Entities.Base;

namespace FluentFlow.Core.Entities;

public class RefreshToken : BaseEntity
{
    public Guid UserId { get; set; }
    public string Token { get; set; } = null!;
    public DateTime ExpiresAt { get; set; }
    public bool IsRevoked { get; set; }
    public string? ReplacedByToken { get; set; }
    public string? CreatedByIp { get; set; }
}