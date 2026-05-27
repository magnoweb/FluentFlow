using FluentFlow.Core.DTOs;
using FluentValidation;

namespace FluentFlow.Api.Validators;

public class SubmitReviewValidator : AbstractValidator<SubmitReviewDto>
{
    public SubmitReviewValidator()
    {
        RuleFor(x => x.SessionId).NotEmpty();
        RuleFor(x => x.CardId).NotEmpty();
        RuleFor(x => x.Score).InclusiveBetween(0, 5);
        RuleFor(x => x.SimilarityScore)
            .InclusiveBetween(0.0, 1.0)
            .When(x => x.SimilarityScore.HasValue);
    }
}