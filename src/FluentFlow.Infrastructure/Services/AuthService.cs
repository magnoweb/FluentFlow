using FluentFlow.Core.Common;
using FluentFlow.Core.DTOs.Auth;
using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Core.Interfaces;
using FluentFlow.Infrastructure.Data;
using FluentFlow.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Services;

public class AuthService(
    UserManager<ApplicationUser> userManager,
    FluentFlowDbContext db,
    TokenService tokenService) : IAuthService
{
    public async Task<Result<AuthResultDto>> RegisterAsync(RegisterDto dto, string ipAddress)
    {
        // Verificar se o email já existe
        if (await userManager.FindByEmailAsync(dto.Email) is not null)
            return Result<AuthResultDto>.Failure("Email já registado.");

        var user = new ApplicationUser
        {
            Name     = dto.Name,
            Email    = dto.Email,
            UserName = dto.Email,
            UserType = UserType.Standard,
            IsEnabled = true,
        };

        var result = await userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded)
        {
            var errors = string.Join("; ", result.Errors.Select(e => e.Description));
            return Result<AuthResultDto>.Failure(errors);
        }

        return await IssueTokensAsync(user, ipAddress);
    }

    public async Task<Result<AuthResultDto>> LoginAsync(LoginDto dto, string ipAddress)
    {
        var user = await userManager.FindByEmailAsync(dto.Email);

        if (user is null || !user.IsEnabled)
            return Result<AuthResultDto>.Failure(LocalizationHelper.Get("Api.InvalidCredentials"));

        if (!await userManager.CheckPasswordAsync(user, dto.Password))
            return Result<AuthResultDto>.Failure(LocalizationHelper.Get("Api.InvalidCredentials"));

        return await IssueTokensAsync(user, ipAddress);
    }

    public async Task<Result<AuthResultDto>> RefreshAsync(string refreshToken, string ipAddress)
    {
        var stored = await db.RefreshTokens
            .FirstOrDefaultAsync(t => t.Token == refreshToken && !t.IsRevoked);

        if (stored is null || stored.ExpiresAt < DateTime.UtcNow)
            return Result<AuthResultDto>.Failure(LocalizationHelper.Get("Api.RefreshTokenInvalid"));

        var user = await userManager.FindByIdAsync(stored.UserId.ToString());
        if (user is null || !user.IsEnabled)
            return Result<AuthResultDto>.Failure(LocalizationHelper.Get("Api.UserNotFound"));

        // Revogar o token antigo
        stored.IsRevoked = true;

        // Emitir novo par de tokens
        var authResult = await IssueTokensAsync(user, ipAddress);

        // Registar qual token substituiu este
        stored.ReplacedByToken = authResult.Value!.RefreshToken;
        await db.SaveChangesAsync();

        return authResult;
    }

    public async Task<Result> RevokeAsync(string refreshToken)
    {
        var stored = await db.RefreshTokens
            .FirstOrDefaultAsync(t => t.Token == refreshToken && !t.IsRevoked);

        if (stored is null)
            return Result.Failure(LocalizationHelper.Get("Api.TokenNotFound"));

        stored.IsRevoked = true;
        await db.SaveChangesAsync();
        return Result.Success();
    }

    public async Task<Result<AuthResultDto>> SocialLoginAsync(string provider, string providerUserId, string email, string name, string ipAddress)
    {
        // Verificar se já existe login social registado
        var user = await userManager.FindByLoginAsync(provider, providerUserId);

        if (user is null)
        {
            // Verificar se já existe conta com o mesmo email
            user = await userManager.FindByEmailAsync(email);

            if (user is null)
            {
                // Criar nova conta
                user = new ApplicationUser
                {
                    Name = name,
                    Email = email,
                    UserName = email,
                    UserType = UserType.Standard,
                    IsEnabled = true,
                    EmailConfirmed = true, // social login = email verificado
                };

                var createResult = await userManager.CreateAsync(user);
                if (!createResult.Succeeded)
                {
                    var errors = string.Join("; ", createResult.Errors.Select(e => e.Description));
                    return Result<AuthResultDto>.Failure(errors);
                }
            }

            // Associar o login social à conta
            await userManager.AddLoginAsync(user, new UserLoginInfo(provider, providerUserId, provider));
        }

        if (!user.IsEnabled)
            return Result<AuthResultDto>.Failure(LocalizationHelper.Get("Api.AccountDisabled"));

        return await IssueTokensAsync(user, ipAddress);
    }

    // ── Profile ────────────────────────────────────────────────────────────────
    public async Task<Result<UserProfileDto>> GetProfileAsync(Guid userId)
    {
        var user = await userManager.FindByIdAsync(userId.ToString());
        if (user is null) return Result<UserProfileDto>.Failure(LocalizationHelper.Get("Api.UserNotFound"));
        return Result<UserProfileDto>.Success(ToProfileDto(user));
    }

    public async Task<Result<UserProfileDto>> UpdateProfileAsync(Guid userId, UpdateProfileDto dto)
    {
        var user = await userManager.FindByIdAsync(userId.ToString());
        if (user is null) return Result<UserProfileDto>.Failure(LocalizationHelper.Get("Api.UserNotFound"));

        // ── Nome ──────────────────────────────────────────────────────────────────
        user.Name = dto.Name;

        // ── Email ─────────────────────────────────────────────────────────────────
        if (!string.Equals(user.Email, dto.Email, StringComparison.OrdinalIgnoreCase))
        {
            var emailInUse = await userManager.FindByEmailAsync(dto.Email);
            if (emailInUse is not null && emailInUse.Id != user.Id)
                return Result<UserProfileDto>.Failure(LocalizationHelper.Get("Api.EmailAlreadyInUse"));

            user.Email = dto.Email;
            user.UserName = dto.Email;
            user.NormalizedEmail = dto.Email.ToUpperInvariant();
            user.NormalizedUserName = dto.Email.ToUpperInvariant();
        }

        // ── Password ──────────────────────────────────────────────────────────────
        if (!string.IsNullOrWhiteSpace(dto.NewPassword))
        {
            if (string.IsNullOrWhiteSpace(dto.CurrentPassword))
                return Result<UserProfileDto>.Failure(LocalizationHelper.Get("Api.CurrentPasswordRequired"));

            var passwordOk = await userManager.CheckPasswordAsync(user, dto.CurrentPassword);
            if (!passwordOk)
                return Result<UserProfileDto>.Failure(LocalizationHelper.Get("Api.CurrentPasswordWrong"));

            var removeResult = await userManager.RemovePasswordAsync(user);
            if (!removeResult.Succeeded)
                return Result<UserProfileDto>.Failure(LocalizationHelper.Get("Api.PasswordRemoveFailed"));

            var addResult = await userManager.AddPasswordAsync(user, dto.NewPassword);
            if (!addResult.Succeeded)
            {
                var errors = string.Join("; ", addResult.Errors.Select(e => e.Description));
                return Result<UserProfileDto>.Failure(errors);
            }
        }

        // ── Avatar ────────────────────────────────────────────────────────────────
        if (dto.ProfileImageBase64 is not null)
        {
            user.ProfileImageUrl = dto.ProfileImageBase64 == "" ? null : dto.ProfileImageBase64;
        }

        var updateResult = await userManager.UpdateAsync(user);
        if (!updateResult.Succeeded)
        {
            var errors = string.Join("; ", updateResult.Errors.Select(e => e.Description));
            return Result<UserProfileDto>.Failure(errors);
        }

        return Result<UserProfileDto>.Success(ToProfileDto(user));
    }
    
    // ── Helpers ────────────────────────────────────────────────────────────────
    private async Task<Result<AuthResultDto>> IssueTokensAsync(ApplicationUser user, string ipAddress)
    {
        var accessToken = tokenService.GenerateAccessToken(user);
        var refreshToken = tokenService.GenerateRefreshToken();
        var expiresAt = DateTime.UtcNow.AddMinutes(double.Parse("60")); // mesmo valor do Jwt:ExpiryMinutes

        // Guardar refresh token
        db.RefreshTokens.Add(new RefreshToken
        {
            UserId = user.Id,
            Token = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(tokenService.RefreshExpiryDays),
            CreatedByIp = ipAddress,
        });
        await db.SaveChangesAsync();

        return Result<AuthResultDto>.Success(new AuthResultDto(accessToken, refreshToken, expiresAt,
            new UserInfoDto(user.Id, user.Name, user.Email!, user.UserType.ToString(), user.ProfileImageUrl)));
    }
    
    private static UserProfileDto ToProfileDto(ApplicationUser u) => new(
        u.Id, u.Name, u.Email!, u.UserType.ToString(), u.ProfileImageUrl, u.CreatedAt);
}