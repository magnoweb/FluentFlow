namespace FluentFlow.Core.Interfaces;

public interface IPhoneticService
{
    /// <summary>
    /// Converte texto para representação fonética no idioma especificado.
    /// Suporta: en, pt, es, fr.
    /// Retorna null se o idioma não for suportado ou ocorrer erro.
    /// </summary>
    string? Convert(string text, string language);
}