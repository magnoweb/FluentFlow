using FluentFlow.Core.Entities.Base;

namespace FluentFlow.Core.Entities;

public class TranslationCache : BaseEntity
{
    public string SourceText     { get; set; } = null!;
    public string TranslatedText { get; set; } = null!;
    public string FromLanguage   { get; set; } = null!;
    public string ToLanguage     { get; set; } = null!;
}