using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs.Auth;

namespace FluentFlow.Core.Interfaces;

public interface IAuthService
{
    Task<Result<AuthResultDto>> RegisterAsync(RegisterDto dto, string ipAddress, string platform);
    Task<Result<AuthResultDto>> LoginAsync(LoginDto dto, string ipAddress, string platform);
    Task<Result<AuthResultDto>> RefreshAsync(string refreshToken, string ipAddress, string platform);
    Task<Result> RevokeAsync(string refreshToken);
    Task<Result<AuthResultDto>> SocialLoginAsync(string provider, string providerUserId, string email, string name, string ipAddress, string platform);
    
    // Perfil
    Task<Result<UserProfileDto>> GetProfileAsync(Guid userId);
    Task<Result<UserProfileDto>> UpdateProfileAsync(Guid userId, UpdateProfileDto dto);
}