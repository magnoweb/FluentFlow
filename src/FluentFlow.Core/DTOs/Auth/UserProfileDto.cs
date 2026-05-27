namespace FluentFlow.Core.DTOs.Auth;

public record UserProfileDto(
    Guid    Id,
    string  Name,
    string  Email,
    string  UserType,
    string? ProfileImageBase64,
    DateTime CreatedAt
);

public class UpdateProfileDto
{
    public string Name { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string? CurrentPassword { get; set; }
    public string? NewPassword { get; set; }
    public string? ProfileImageBase64 { get; set; }    
}
