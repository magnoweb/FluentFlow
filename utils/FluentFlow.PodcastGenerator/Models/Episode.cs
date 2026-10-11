using System.Text.Json.Serialization;

namespace FluentFlow.PodcastGenerator.Models;

/// <summary>Episódio de podcast lido de Input/*.json.</summary>
public sealed class Episode
{
    /// <summary>Identificador usado no nome dos ficheiros de saída (ex.: "en-a2-001").</summary>
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public string? Description { get; set; }

    /// <summary>Idioma estudado no episódio (idioma por omissão dos speakers), ex.: "en-US".</summary>
    public string Language { get; set; } = "en-US";

    /// <summary>Nível CEFR (A1..C2) — apenas metadado.</summary>
    public string? Level { get; set; }

    /// <summary>Nome da série, quando o episódio faz parte de uma (ex.: "Ship It"). Opcional.</summary>
    public string? Series { get; set; }

    /// <summary>Temporada da série. Opcional.</summary>
    public int? Season { get; set; }

    /// <summary>Número do episódio dentro da temporada. Opcional.</summary>
    public int? EpisodeNumber { get; set; }

    /// <summary>Pausa por omissão entre falas (ms). Se nulo, usa a configuração.</summary>
    public int? DefaultPauseMs { get; set; }

    public Dictionary<string, SpeakerDefinition> Speakers { get; set; } = new(StringComparer.OrdinalIgnoreCase);

    public List<Segment> Segments { get; set; } = [];
}

public sealed class SpeakerDefinition
{
    /// <summary>Nome da voz Azure, ex.: "en-US-JennyNeural".</summary>
    public string Voice { get; set; } = "";

    /// <summary>Idioma em que este speaker fala (ex.: "pt-BR" para o narrador). Se nulo, usa Episode.Language.</summary>
    public string? Language { get; set; }

    /// <summary>
    /// Vozes a usar quando o texto marca outro idioma, ex.: { "en-US": "en-US-AndrewNeural" }.
    /// Assim, "[en]take care[/en]" dentro de uma fala em pt-BR é dito por uma voz nativa inglesa.
    /// Sem entrada aqui, usa &lt;lang&gt; na própria voz (exige voz *Multilingual*).
    /// </summary>
    public Dictionary<string, string>? AltVoices { get; set; }

    /// <summary>Velocidade relativa (prosody rate), ex.: "-10%", "+5%". Opcional.</summary>
    public string? Rate { get; set; }

    /// <summary>Tom (prosody pitch), ex.: "+2st", "-5%". Opcional.</summary>
    public string? Pitch { get; set; }

    /// <summary>Estilo mstts:express-as (só algumas vozes), ex.: "cheerful", "friendly". Opcional.</summary>
    public string? Style { get; set; }
}

public sealed class Segment
{
    /// <summary>Chave em <see cref="Episode.Speakers"/>.</summary>
    public string Speaker { get; set; } = "";

    /// <summary>
    /// Texto da fala. Marcação suportada:
    ///   [en]...[/en] ou [en-US]...[/en-US]  → trecho noutro idioma
    ///   [slow]...[/slow]                     → trecho lento (pronúncia)
    ///   [pause] ou [pause 800]               → pausa (ms; por omissão 600)
    /// </summary>
    public string Text { get; set; } = "";

    /// <summary>Secção do episódio (ex.: "intro", "dialogue", "review", "outro"). Opcional.</summary>
    public string? Section { get; set; }

    /// <summary>Tradução opcional (não é sintetizada, vai para a transcrição).</summary>
    public string? Translation { get; set; }

    /// <summary>Pausa após esta fala (ms). Se nulo, usa DefaultPauseMs.</summary>
    public int? PauseAfterMs { get; set; }

    /// <summary>Sobrepõe o estilo do speaker apenas nesta fala. Opcional.</summary>
    public string? Style { get; set; }

    /// <summary>Sobrepõe o rate do speaker apenas nesta fala. Opcional.</summary>
    public string? Rate { get; set; }
}

/// <summary>Transcrição com timestamps gravada em Output/{id}.json.</summary>
public sealed class EpisodeTranscript
{
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public string? Description { get; set; }
    public string Language { get; set; } = "";
    public string? Level { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Series { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int? Season { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int? EpisodeNumber { get; set; }

    public int DurationMs { get; set; }
    public string AudioFile { get; set; } = "";

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? SlowAudioFile { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public double? SlowTempo { get; set; }

    public DateTimeOffset GeneratedAtUtc { get; set; }
    public List<TranscriptLine> Lines { get; set; } = [];
}

public sealed class TranscriptLine
{
    public int Index { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Section { get; set; }

    public string Speaker { get; set; } = "";
    public string Text { get; set; } = "";

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Translation { get; set; }

    public int StartMs { get; set; }
    public int EndMs { get; set; }
}
