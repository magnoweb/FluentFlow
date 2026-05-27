namespace FluentFlow.Core.Interfaces;

public interface IAudioConverterService
{
    /// <summary>
    /// Converte qualquer ficheiro de áudio para WAV PCM 16kHz mono
    /// (formato requerido pelo Whisper.net).
    /// Retorna o path do ficheiro temporário gerado.
    /// O chamador é responsável por apagar o ficheiro após uso.
    /// </summary>
    Task<string> ConvertToWavAsync(string inputPath);
}