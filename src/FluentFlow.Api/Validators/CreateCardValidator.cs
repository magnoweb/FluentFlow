using FluentFlow.Core.DTOs;
using FluentValidation;

namespace FluentFlow.Api.Validators;

public class CreateCardValidator : AbstractValidator<CreateCardDto>
{
    public CreateCardValidator()
    {
        RuleFor(x => x.Front).NotEmpty().MaximumLength(1000);
        RuleFor(x => x.Back).NotEmpty().MaximumLength(1000);
        RuleFor(x => x.Pronunciation).MaximumLength(500);
    }
}