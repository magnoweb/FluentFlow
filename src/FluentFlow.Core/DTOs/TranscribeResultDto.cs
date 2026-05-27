namespace FluentFlow.Core.DTOs;

public record TranscribeResultDto(
    string TranscribedText,
    double SimilarityRatio   // 0.0 – 1.0
);