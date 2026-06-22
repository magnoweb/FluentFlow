namespace FluentFlow.Core.Interfaces;

public interface IPhoneticService
{
    /// <summary>
    /// Converte texto em inglês para a representação fonética (Lytspel).
    /// Retorna null se o texto parecer escrito noutra língua.
    /// </summary>
    string? Convert(string text);
}