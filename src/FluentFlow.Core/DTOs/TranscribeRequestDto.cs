namespace FluentFlow.Core.DTOs;

public record TranscribeRequestDto(
    string AudioBase64,
    string Extension,
    string OriginalText,  // texto original para cálculo de similaridade
    string Language       // ex: "en"
);