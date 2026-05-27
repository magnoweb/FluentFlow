namespace FluentFlow.Core.DTOs.Auth;

public record UpdateProfileDto(
    string  Name,
    string  Email,
    string? CurrentPassword,   // obrigatório se mudar a password
    string? NewPassword,
    string? ProfileImageBase64 // null = não alterar | "" = remover
);