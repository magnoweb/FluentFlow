using System.Security;
using System.Text;
using System.Text.RegularExpressions;
using FluentFlow.PodcastGenerator.Models;

namespace FluentFlow.PodcastGenerator.Services;

/// <summary>
/// Converte o texto de uma fala (com marcação simples) em SSML do Azure.
///
/// Marcação:
///   [en]...[/en], [en-US]...[/en-US]  trecho noutro idioma. Se o speaker tiver AltVoices para esse
///                                     idioma, o trecho é dito por essa voz; senão usa &lt;lang&gt; (voz Multilingual).
///   [slow]...[/slow]                  trecho lento, para demonstrar pronúncia.
///   [pause] / [pause 800]             pausa em ms (600 por omissão).
/// </summary>
public static partial class SsmlBuilder
{
    public const string SlowRate = "-35%";
    public const int DefaultInlinePauseMs = 600;

    private static readonly Dictionary<string, string> DefaultLocales = new(StringComparer.OrdinalIgnoreCase)
    {
        ["en"] = "en-US",
        ["pt"] = "pt-BR",
        ["es"] = "es-ES",
        ["fr"] = "fr-FR",
    };

    [GeneratedRegex(@"\[(?<close>/)?(?<tag>slow|[a-zA-Z]{2}(?:-[a-zA-Z]{2})?)\]|\[pause(?:\s+(?<ms>\d+))?\]", RegexOptions.IgnoreCase)]
    private static partial Regex TagRegex();

    [GeneratedRegex(@"\s{2,}")]
    private static partial Regex MultiSpaceRegex();

    private abstract record Token;
    private sealed record TextToken(string Text, string? Lang, bool Slow) : Token;
    private sealed record PauseToken(int Ms) : Token;

    /// <summary>Texto sem marcação (para a transcrição).</summary>
    public static string ToPlainText(string text) =>
        MultiSpaceRegex().Replace(TagRegex().Replace(text, " "), " ").Trim()
            .Replace(" ,", ",").Replace(" .", ".").Replace(" ?", "?").Replace(" !", "!");

    public static string Build(string episodeLanguage, SpeakerDefinition speaker, Segment segment)
    {
        var baseLang = speaker.Language ?? episodeLanguage;
        var tokens = Tokenize(segment.Text, baseLang, speaker);
        var rate = segment.Rate ?? speaker.Rate;
        var style = segment.Style ?? speaker.Style;

        var sb = new StringBuilder();
        sb.Append("<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\" ")
          .Append("xmlns:mstts=\"https://www.w3.org/2001/mstts\" xml:lang=\"").Append(Esc(baseLang)).Append("\">");

        // Agrupa tokens consecutivos com a mesma voz num único <voice>.
        var groups = new List<(string Voice, bool IsBase, List<Token> Tokens)>();
        foreach (var token in tokens)
        {
            var voice = token is TextToken t ? VoiceFor(t.Lang, baseLang, speaker) : groups.LastOrDefault().Voice ?? speaker.Voice;
            if (groups.Count == 0 || groups[^1].Voice != voice)
                groups.Add((voice, voice == speaker.Voice, new List<Token>()));
            groups[^1].Tokens.Add(token);
        }

        foreach (var (voice, isBase, groupTokens) in groups)
        {
            var content = new StringBuilder();
            var hasLang = false;
            foreach (var token in groupTokens)
            {
                switch (token)
                {
                    case PauseToken p:
                        content.Append("<break time=\"").Append(p.Ms).Append("ms\"/>");
                        break;

                    case TextToken t:
                        // Cada trecho leva o seu próprio <prosody> (evita prosody aninhado e lang dentro de prosody).
                        var tokenRate = t.Slow ? SlowRate : rate;
                        var pitch = isBase ? speaker.Pitch : null;
                        var inner = Prosody(Esc(t.Text), tokenRate, pitch);

                        var needsLangTag = isBase && t.Lang is not null && !SameLang(t.Lang, baseLang);
                        if (needsLangTag)
                        {
                            hasLang = true;
                            inner = $"<lang xml:lang=\"{Esc(t.Lang!)}\">{inner}</lang>";
                        }
                        content.Append(inner);
                        break;
                }
            }

            var body = content.ToString();
            // express-as só na voz principal e quando não há <lang> (combinação nem sempre suportada).
            if (isBase && !hasLang && !string.IsNullOrWhiteSpace(style))
                body = $"<mstts:express-as style=\"{Esc(style)}\">{body}</mstts:express-as>";

            sb.Append("<voice name=\"").Append(Esc(voice)).Append("\">").Append(body).Append("</voice>");
        }

        sb.Append("</speak>");
        return sb.ToString();
    }

    private static List<Token> Tokenize(string text, string baseLang, SpeakerDefinition speaker)
    {
        var tokens = new List<Token>();
        var langStack = new Stack<(string Tag, string Locale)>();
        var slowDepth = 0;
        var pos = 0;

        foreach (Match m in TagRegex().Matches(text))
        {
            AddText(text[pos..m.Index]);
            pos = m.Index + m.Length;

            if (m.Value.StartsWith("[pause", StringComparison.OrdinalIgnoreCase))
            {
                tokens.Add(new PauseToken(m.Groups["ms"].Success ? int.Parse(m.Groups["ms"].Value) : DefaultInlinePauseMs));
                continue;
            }

            var tag = m.Groups["tag"].Value;
            var closing = m.Groups["close"].Success;

            if (tag.Equals("slow", StringComparison.OrdinalIgnoreCase))
            {
                if (closing && slowDepth == 0) throw new FormatException("[/slow] sem [slow] correspondente.");
                slowDepth += closing ? -1 : 1;
                continue;
            }

            if (closing)
            {
                if (langStack.Count == 0 || !langStack.Peek().Tag.Equals(tag, StringComparison.OrdinalIgnoreCase))
                    throw new FormatException($"[/{tag}] não corresponde à última tag de idioma aberta.");
                langStack.Pop();
            }
            else
            {
                langStack.Push((tag, ResolveLocale(tag, baseLang, speaker)));
            }
        }
        AddText(text[pos..]);

        if (slowDepth != 0) throw new FormatException("[slow] sem [/slow].");
        if (langStack.Count != 0) throw new FormatException($"[{langStack.Peek().Tag}] sem [/{langStack.Peek().Tag}].");
        if (!tokens.OfType<TextToken>().Any()) throw new FormatException("Fala sem texto.");
        return tokens;

        void AddText(string raw)
        {
            if (string.IsNullOrWhiteSpace(raw)) return;
            var lang = langStack.Count > 0 ? langStack.Peek().Locale : null;
            tokens.Add(new TextToken(MultiSpaceRegex().Replace(raw.ReplaceLineEndings(" "), " "), lang, slowDepth > 0));
        }
    }

    private static string ResolveLocale(string tag, string baseLang, SpeakerDefinition speaker)
    {
        if (tag.Contains('-')) return tag;
        var candidates = (speaker.AltVoices?.Keys ?? Enumerable.Empty<string>()).Append(baseLang);
        var match = candidates.FirstOrDefault(c => c.StartsWith(tag + "-", StringComparison.OrdinalIgnoreCase));
        return match ?? (DefaultLocales.TryGetValue(tag, out var loc) ? loc : throw new FormatException($"Idioma desconhecido: [{tag}]"));
    }

    private static string VoiceFor(string? lang, string baseLang, SpeakerDefinition speaker)
    {
        if (lang is null || SameLang(lang, baseLang) || speaker.AltVoices is null) return speaker.Voice;
        var alt = speaker.AltVoices.FirstOrDefault(kv => SameLang(kv.Key, lang));
        return alt.Value ?? speaker.Voice;
    }

    private static bool SameLang(string a, string b) => a.Equals(b, StringComparison.OrdinalIgnoreCase);

    private static string Prosody(string text, string? rate, string? pitch)
    {
        if (string.IsNullOrWhiteSpace(rate) && string.IsNullOrWhiteSpace(pitch)) return text;
        var sb = new StringBuilder("<prosody");
        if (!string.IsNullOrWhiteSpace(rate)) sb.Append(" rate=\"").Append(Esc(rate)).Append('"');
        if (!string.IsNullOrWhiteSpace(pitch)) sb.Append(" pitch=\"").Append(Esc(pitch)).Append('"');
        return sb.Append('>').Append(text).Append("</prosody>").ToString();
    }

    private static string Esc(string s) => SecurityElement.Escape(s) ?? "";
}
