namespace FluentFlow.Core.DTOs.Auth;

public record RegisterDto(
    string Name,
    string Email,
    string Password
);

public record LoginDto(
    string Email,
    string Password
);

public record AuthResultDto(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt,
    UserInfoDto User
);

public record UserInfoDto(
    Guid Id,
    string Name,
    string Email,
    string UserType,
    string? ProfileImageUrl
);

public record RefreshTokenDto(string RefreshToken);