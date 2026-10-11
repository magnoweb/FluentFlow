using System.Text;
using FluentFlow.PodcastGenerator.Models;
using FluentFlow.PodcastGenerator.Services;
using Microsoft.Extensions.Configuration;

// FluentFlow Podcast Generator
// Uso:
//   dotnet run                         → gera todos os episódios de Input/*.json ainda não gerados (ou alterados)
//   dotnet run -- ep001.json           → gera apenas os ficheiros indicados
//   dotnet run -- --force              → regenera mesmo que o MP3 já exista
//   dotnet run -- --validate           → só valida os JSON (não chama o Azure)
// Ficheiros em Input começados por "_" (ex.: _template.json) são ignorados.

Console.OutputEncoding = Encoding.UTF8;
using var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

var force = args.Contains("--force", StringComparer.OrdinalIgnoreCase);
var validateOnly = args.Contains("--validate", StringComparer.OrdinalIgnoreCase);
var requested = args.Where(a => !a.StartsWith("--", StringComparison.Ordinal)).ToList();

var projectRoot = FindProjectRoot();
// Utilitário de desenvolvimento: por omissão o ambiente é "Development" (sobrepõe com DOTNET_ENVIRONMENT).
var environment = Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT") ?? "Development";
var configuration = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: false)
    .AddJsonFile($"appsettings.{environment}.json", optional: true)
    .AddUserSecrets<Program>(optional: true)
    .AddEnvironmentVariables()
    .Build();

var settings = configuration.GetSection("Podcast").Get<PodcastSettings>() ?? new PodcastSettings();
var azure = configuration.GetSection("AzureSpeech").Get<AzureSpeechSettings>() ?? new AzureSpeechSettings();

var inputDir = Path.GetFullPath(Path.Combine(projectRoot, settings.InputDirectory));
var outputDir = Path.GetFullPath(Path.Combine(projectRoot, settings.OutputDirectory));
var cacheDir = Path.GetFullPath(Path.Combine(projectRoot, settings.CacheDirectory));
Directory.CreateDirectory(inputDir);
Directory.CreateDirectory(outputDir);

// FFmpeg: caminho relativo ao projecto (por omissão o da API); se não existir, usa o do PATH.
if (settings.FfmpegPath.IndexOfAny(['/', '\\']) >= 0)
{
    var resolved = Path.GetFullPath(Path.Combine(projectRoot, settings.FfmpegPath));
    settings.FfmpegPath = File.Exists(resolved) ? resolved : "ffmpeg";
}

Console.WriteLine("FluentFlow Podcast Generator");
Console.WriteLine($"  Input : {inputDir}");
Console.WriteLine($"  Output: {outputDir}");
Console.WriteLine();

// Selecção dos ficheiros a processar
var files = requested.Count > 0
    ? requested.Select(f => Path.IsPathRooted(f) ? f : Path.Combine(inputDir, f)).ToList()
    : Directory.EnumerateFiles(inputDir, "*.json")
        .Where(f => !Path.GetFileName(f).StartsWith('_'))
        .OrderBy(f => f, StringComparer.OrdinalIgnoreCase)
        .ToList();

if (files.Count == 0)
{
    Console.WriteLine("Nenhum episódio encontrado em Input. Copia Input/_template.json para começar.");
    return 0;
}

// Validação de todos antes de gastar quota
var episodes = new List<(string File, Episode Episode)>();
var invalid = 0;
foreach (var file in files)
{
    try
    {
        if (!File.Exists(file)) throw new FileNotFoundException("Ficheiro não encontrado.", file);
        var ep = await EpisodeGenerator.LoadAsync(file, cts.Token);
        episodes.Add((file, ep));
        Console.WriteLine($"✓ {Path.GetFileName(file)} — \"{ep.Title}\" ({ep.Segments.Count} falas, {ep.Segments.Sum(s => s.Text.Length)} caracteres)");
    }
    catch (Exception ex) when (ex is not OperationCanceledException)
    {
        invalid++;
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine($"✗ {Path.GetFileName(file)}:{Environment.NewLine}{ex.Message}");
        Console.ResetColor();
    }
}

var duplicates = episodes.GroupBy(e => e.Episode.Id, StringComparer.OrdinalIgnoreCase).Where(g => g.Count() > 1).ToList();
foreach (var d in duplicates)
{
    invalid++;
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine($"✗ Id duplicado '{d.Key}' em: {string.Join(", ", d.Select(x => Path.GetFileName(x.File)))}");
    Console.ResetColor();
}

if (validateOnly || invalid > 0)
{
    Console.WriteLine();
    Console.WriteLine(invalid > 0 ? $"{invalid} ficheiro(s) com erros. Nada foi gerado." : "Validação concluída.");
    return invalid > 0 ? 1 : 0;
}

// Geração
var encoder = new FfmpegEncoder(settings);
await encoder.EnsureAvailableAsync(cts.Token);

using var tts = new AzureTtsService(azure, cacheDir);
var generator = new EpisodeGenerator(settings, tts, encoder, outputDir);

int generated = 0, skipped = 0, failed = 0;
foreach (var (file, episode) in episodes)
{
    var mp3 = Path.Combine(outputDir, $"{episode.Id}.mp3");
    if (!force && File.Exists(mp3) && File.GetLastWriteTimeUtc(mp3) >= File.GetLastWriteTimeUtc(file))
    {
        Console.WriteLine($"\n• {episode.Id}: já gerado (usa --force para regenerar).");
        skipped++;
        continue;
    }

    Console.WriteLine($"\n▶ {episode.Id} — {episode.Title}");
    try
    {
        var t = await generator.GenerateAsync(episode, cts.Token);
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine($"  ✓ {t.AudioFile} ({TimeSpan.FromMilliseconds(t.DurationMs):mm\\:ss})");
        Console.ResetColor();
        generated++;
    }
    catch (OperationCanceledException)
    {
        Console.WriteLine("\nCancelado.");
        return 130;
    }
    catch (Exception ex)
    {
        failed++;
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine($"\n  ✗ Erro: {ex.Message}");
        Console.ResetColor();
    }
}

// Publicação para a pasta lida pela API (só copia o que é novo ou mudou)
if (!string.IsNullOrWhiteSpace(settings.PublishDirectory))
{
    var publishDir = Path.GetFullPath(Path.Combine(projectRoot, settings.PublishDirectory));
    Directory.CreateDirectory(publishDir);
    var published = 0;
    foreach (var (_, episode) in episodes)
    {
        foreach (var name in new[] { $"{episode.Id}.json", $"{episode.Id}.mp3", $"{episode.Id}.slow.mp3" })
        {
            var source = Path.Combine(outputDir, name);
            if (!File.Exists(source)) continue;
            var target = Path.Combine(publishDir, name);
            if (File.Exists(target) && File.GetLastWriteTimeUtc(target) >= File.GetLastWriteTimeUtc(source)) continue;
            File.Copy(source, target, overwrite: true);
            published++;
        }
    }
    Console.WriteLine();
    Console.WriteLine($"Publicado(s) {published} ficheiro(s) em {publishDir}");
}

Console.WriteLine();
Console.WriteLine($"Concluído: {generated} gerado(s), {skipped} ignorado(s), {failed} com erro.");
Console.WriteLine($"Caracteres enviados ao Azure: {tts.CharactersSynthesized} (cache: {tts.CacheHits} fala(s) reutilizada(s)).");
return failed > 0 ? 1 : 0;

// Sobe a partir de bin/... até encontrar o .csproj, para Input/Output ficarem na pasta do projecto
// tanto com "dotnet run" como a correr pelo Visual Studio.
static string FindProjectRoot()
{
    var dir = new DirectoryInfo(AppContext.BaseDirectory);
    while (dir is not null)
    {
        if (dir.EnumerateFiles("FluentFlow.PodcastGenerator.csproj").Any()) return dir.FullName;
        dir = dir.Parent;
    }
    return Directory.GetCurrentDirectory();
}

public partial class Program;
