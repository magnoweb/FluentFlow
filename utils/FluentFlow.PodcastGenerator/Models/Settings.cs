namespace FluentFlow.PodcastGenerator.Models;

public sealed class PodcastSettings
{
    public string InputDirectory { get; set; } = "Input";
    public string OutputDirectory { get; set; } = "Output";
    public string CacheDirectory { get; set; } = "Cache";
    public string FfmpegPath { get; set; } = "ffmpeg";
    public string Bitrate { get; set; } = "96k";
    public int DefaultPauseMs { get; set; } = 500;
    public int LeadingSilenceMs { get; set; } = 300;
    public int TrailingSilenceMs { get; set; } = 800;
    public bool GenerateSlowVersion { get; set; } = true;
    public double SlowTempo { get; set; } = 0.85;
    public bool Normalize { get; set; } = true;

    /// <summary>
    /// Pasta onde a API lê os episódios (ex.: "../../src/FluentFlow.Api/App_Data/Podcasts").
    /// Se definida, os ficheiros gerados (.json/.mp3) são copiados para lá no fim. Vazio = não publicar.
    /// </summary>
    public string? PublishDirectory { get; set; }
}

public sealed class AzureSpeechSettings
{
    public string Key { get; set; } = "";
    public string Region { get; set; } = "westeurope";
}
