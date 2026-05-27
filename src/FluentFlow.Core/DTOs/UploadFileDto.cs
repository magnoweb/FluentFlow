namespace FluentFlow.Core.DTOs;

public sealed class UploadFileDto
{
    public required byte[] Bytes { get; init; }
    public required string FileName { get; init; }
    public required string ContentType { get; init; }
}