using FluentFlow.Core.DTOs;
using FluentValidation;

namespace FluentFlow.Api.Validators;

public class CreateDeckValidator : AbstractValidator<CreateDeckDto>
{
    public CreateDeckValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .MaximumLength(200);

        RuleFor(x => x.Language)
            .NotEmpty().MaximumLength(10);

        RuleFor(x => x.NativeLanguage)
            .NotEmpty().MaximumLength(10);

        RuleFor(x => x.MaxNewCardsPerDay)
            .InclusiveBetween(1, 500);

        RuleFor(x => x.MaxReviewsPerDay)
            .InclusiveBetween(1, 1000);
    }
}