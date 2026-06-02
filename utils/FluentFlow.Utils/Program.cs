using System.Diagnostics;
using System.Text.RegularExpressions;

if (args.Length == 0)
{
    RunInteractiveMenu();
    return;
}

ExecuteCommand(args);
return;

static void ExecuteCommand(string[] args)
{
    switch (args[0].ToLower())
    {
        case "sql":
            RunSqlCompiler(args.Skip(1).ToArray());
            break;
        case "zip":
            RunZipProject(args.Skip(1).ToArray());
            break;
        case "tree":
            RunTree(args.Skip(1).ToArray());
            break;
        case "modified":
            RunCopyModified(args.Skip(1).ToArray());
            break;
        case "help":
        default:
            ShowHelp();
            break;
    }
}

static void RunInteractiveMenu()
{
    while (true)
    {
        Console.Clear();

        Console.WriteLine("========================================");
        Console.WriteLine("           FluentFlow.Utils");
        Console.WriteLine("========================================");
        Console.WriteLine();

        Console.WriteLine("[1] - Compilar scripts SQL");
        Console.WriteLine("[2] - Compactar projeto (ZIP)");
        Console.WriteLine("[3] - Exibir árvore de diretórios");
        Console.WriteLine("[4] - Copiar arquivos do último commit");
        Console.WriteLine("[5] - Ajuda");
        Console.WriteLine("[0] - Sair");
        Console.WriteLine();

        Console.Write("Opção: ");

        if (!int.TryParse(Console.ReadLine(), out var option))
            continue;

        Console.WriteLine();

        switch (option)
        {
            case 0:
                return;
            case 1:
                ExecuteSqlInteractive();
                break;
            case 2:
                ExecuteZipInteractive();
                break;
            case 3:
                ExecuteTreeInteractive();
                break;
            case 4:
                ExecuteModifiedInteractive();
                break;
            case 5:
                ShowHelp();
                Pause();
                break;
        }
    }
}

static void ShowHelp()
{
    Console.WriteLine();
    Console.WriteLine("========================================");
    Console.WriteLine("           FluentFlow.Utils");
    Console.WriteLine("========================================");
    Console.WriteLine();

    Console.WriteLine("Comandos disponíveis:");
    Console.WriteLine();

    Console.WriteLine("sql");
    Console.WriteLine("  Compila scripts SQL");
    Console.WriteLine("  Uso:");
    Console.WriteLine("    FluentFlow.Utils sql <scriptsFolder> <outputFile> <excludeRegex>");
    Console.WriteLine();

    Console.WriteLine("zip");
    Console.WriteLine("  Compacta um projeto em ZIP");
    Console.WriteLine("  Uso:");
    Console.WriteLine("    FluentFlow.Utils zip <sourceDir> <zipFile> [ignorePatternsCsv]");
    Console.WriteLine();

    Console.WriteLine("tree");
    Console.WriteLine("  Exibe a árvore de diretórios");
    Console.WriteLine("  Uso:");
    Console.WriteLine("    FluentFlow.Utils tree <rootDir> [/F] [/A]");
    Console.WriteLine();

    Console.WriteLine("modified");
    Console.WriteLine("  Copia arquivos alterados do último commit");
    Console.WriteLine("  Uso:");
    Console.WriteLine("    FluentFlow.Utils modified <sourceDir> <targetDir>");
    Console.WriteLine();

    Console.WriteLine("Exemplos:");
    Console.WriteLine(@"  FluentFlow.Utils sql ""D:\TFS\...\Scripts"" ""D:\TFS\...\00_All.sql"" ""_Helper_|00_PesquisaClima_v2.sql""");
    Console.WriteLine(@"  FluentFlow.Utils zip ""D:\TFS\FluentFlow_v2\FluentFlow"" ""D:\TFS\FluentFlow_v2\FluentFlow_Compact.zip"" "".idea,.vs,bin,obj,tests""");
    Console.WriteLine(@"  FluentFlow.Utils tree ""D:\TFS\FluentFlow_v2\FluentFlow"" /F /A");
    Console.WriteLine(@"  FluentFlow.Utils modified ""D:\TFS\FluentFlow_v2\FluentFlow"" ""D:\Temp\FluentFlow_Modified""");
    Console.WriteLine();
}

#region Interactive

static void ExecuteSqlInteractive()
{
    Console.Write("Scripts Folder: ");
    var scriptsFolder = Console.ReadLine() ?? "";

    Console.Write("Output File: ");
    var outputFile = Console.ReadLine() ?? "";

    Console.Write("Exclude Regex: ");
    var excludeRegex = Console.ReadLine() ?? "";

    RunSqlCompiler([scriptsFolder, outputFile, excludeRegex]);

    Pause();
}

static void ExecuteZipInteractive()
{
    Console.Write("Source Dir: ");
    var sourceDir = Console.ReadLine() ?? "";

    Console.Write("Zip File: ");
    var zipFile = Console.ReadLine() ?? "";

    Console.Write("Ignore Patterns (opcional): ");
    var ignore = Console.ReadLine();

    RunZipProject(string.IsNullOrWhiteSpace(ignore)
        ? [sourceDir, zipFile]
        : [sourceDir, zipFile, ignore]);

    Pause();
}

static void ExecuteTreeInteractive()
{
    Console.Write("Root Dir: ");
    var rootDir = Console.ReadLine() ?? "";

    Console.Write("Opções (/F /A) opcional: ");
    var options = Console.ReadLine();

    RunTree(string.IsNullOrWhiteSpace(options)
        ? [rootDir]
        : [rootDir, .. options.Split(' ', StringSplitOptions.RemoveEmptyEntries)]);

    Pause();
}

static void ExecuteModifiedInteractive()
{
    Console.Write("Repositório Git: ");
    var sourceDir = Console.ReadLine() ?? "";

    Console.Write("Diretório Destino: ");
    var targetDir = Console.ReadLine() ?? "";

    RunCopyModified([sourceDir, targetDir]);

    Pause();
}

#endregion

static void RunSqlCompiler(string[] args)
{
    if (args.Length < 3)
    {
        Console.WriteLine("Parâmetros inválidos para 'sql'.");
        Console.WriteLine("Uso: sql <scriptsFolder> <outputFile> <excludeRegex>");
        return;
    }

    var scriptsFolder = args[0];
    var scriptsOutput = args[1];
    var excludeRegex = args[2];

    if (!Directory.Exists(scriptsFolder))
    {
        Console.WriteLine($"Pasta não encontrada: {scriptsFolder}");
        return;
    }

    var regex = new Regex(excludeRegex, RegexOptions.IgnoreCase);

    if (File.Exists(scriptsOutput))
        File.Delete(scriptsOutput);

    var allLines = Directory
        .GetFiles(scriptsFolder, "*.sql", SearchOption.AllDirectories)
        .Where(name => !regex.IsMatch(name))
        .SelectMany(File.ReadLines);

    Directory.CreateDirectory(Path.GetDirectoryName(scriptsOutput)!);
    File.WriteAllLines(scriptsOutput, allLines);

    Console.WriteLine();
    Console.WriteLine("---------------------------------");
    Console.WriteLine("SQL compilado com sucesso!");
    Console.WriteLine("---------------------------------");
    Console.WriteLine();
}

static void RunZipProject(string[] args)
{
    if (args.Length < 2)
    {
        Console.WriteLine("Parâmetros inválidos para 'zip'.");
        Console.WriteLine("Uso: zip <sourceDir> <zipFile> [ignorePatternsCsv]");
        return;
    }

    var sourceDir = args[0];
    var zipFile = args[1];
    var ignorePatternsCsv = args.Length >= 3 
        ? args[2] 
        : ".idea,.vs,bin,obj,tests,lib,build,.dart_tool,.pub-cache,.flutter-plugins,.flutter-plugins-dependencies,App_Data,WhisperModels";

    if (!Directory.Exists(sourceDir))
    {
        Console.WriteLine($"Pasta não encontrada: {sourceDir}");
        return;
    }

    var ignorePatterns = ignorePatternsCsv
        .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
        .ToArray();

    var tempDir = Path.Combine(Path.GetTempPath(), "ZipPrepare_" + DateTime.Now.ToString("yyyyMMddHHmmss"));
    Directory.CreateDirectory(tempDir);

    Console.WriteLine("Copiando arquivos e aplicando filtros...");

    foreach (var item in Directory.EnumerateFileSystemEntries(sourceDir, "*", SearchOption.AllDirectories))
    {
        var name = Path.GetFileName(item);
        var fullPath = Path.GetFullPath(item);

        var ignore = ignorePatterns.Any(p =>
            name.Like(p) ||
            fullPath.Contains(Path.DirectorySeparatorChar + p + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase));

        if (ignore) continue;

        var relative = fullPath.Substring(sourceDir.Length).TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        var targetPath = Path.Combine(tempDir, relative);

        if (Directory.Exists(item))
        {
            Directory.CreateDirectory(targetPath);
        }
        else
        {
            Directory.CreateDirectory(Path.GetDirectoryName(targetPath)!);
            File.Copy(item, targetPath, true);
        }
    }

    Console.WriteLine("Criando arquivo ZIP...");

    if (File.Exists(zipFile))
        File.Delete(zipFile);

    System.IO.Compression.ZipFile.CreateFromDirectory(tempDir, zipFile);

    Console.WriteLine("Limpando arquivos temporários...");
    Directory.Delete(tempDir, true);

    Console.WriteLine($"Concluído! Arquivo salvo em: {zipFile}");
}

static void RunTree(string[] args)
{
    if (args.Length < 1)
    {
        Console.WriteLine("Parâmetros inválidos para 'tree'.");
        Console.WriteLine("Uso: tree <rootDir> [/F] [/A]");
        return;
    }

    var rootDir = args[0];

    if (!Directory.Exists(rootDir))
    {
        Console.WriteLine($"Pasta não encontrada: {rootDir}");
        return;
    }

    var extraArgs = string.Join(' ', args.Skip(1));
    var psi = new ProcessStartInfo
    {
        FileName = "cmd.exe",
        Arguments = $"/C tree \"{rootDir}\" {extraArgs}",
        UseShellExecute = false,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        CreateNoWindow = true
    };

    using var proc = Process.Start(psi)!;
    var output = proc.StandardOutput.ReadToEnd();
    var error = proc.StandardError.ReadToEnd();
    proc.WaitForExit();

    Console.WriteLine(output);
    if (!string.IsNullOrWhiteSpace(error))
        Console.WriteLine(error);
}

static void RunCopyModified(string[] args)
{
    if (args.Length < 2)
    {
        Console.WriteLine("Parâmetros inválidos para 'modified'.");
        Console.WriteLine("Uso: modified <sourceDir> <targetDir>");
        return;
    }

    var sourceDir = Path.GetFullPath(args[0]);
    var targetDir = Path.GetFullPath(args[1]);

    if (!Directory.Exists(sourceDir))
    {
        Console.WriteLine($"Pasta não encontrada: {sourceDir}");
        return;
    }
    
    if (Directory.Exists(targetDir))
    {
        Console.WriteLine($"Limpando diretório de destino: {targetDir}");
        Directory.Delete(targetDir, true);
    }

    Directory.CreateDirectory(targetDir);

    Console.WriteLine("Obtendo arquivos modificados do último commit...");
    /*
     * ainda não commitadas: "diff --name-only HEAD"
     * tudo que mudou: "diff --name-only origin/main...HEAD"
     */
    var psi = new ProcessStartInfo
    {
        FileName = "git",
        Arguments = "diff --name-only HEAD",
        WorkingDirectory = sourceDir,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false,
        CreateNoWindow = true
    };

    using var process = Process.Start(psi);

    if (process == null)
    {
        Console.WriteLine("Não foi possível executar o Git.");
        return;
    }

    var output = process.StandardOutput.ReadToEnd();
    var error = process.StandardError.ReadToEnd();

    process.WaitForExit();

    if (process.ExitCode != 0)
    {
        Console.WriteLine("Erro ao executar Git:");
        Console.WriteLine(error);
        return;
    }

    var modifiedFiles = output
        .Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
        .Distinct()
        .ToList();

    if (modifiedFiles.Count == 0)
    {
        Console.WriteLine("Nenhum arquivo modificado encontrado.");
        return;
    }

    Console.WriteLine($"Encontrados {modifiedFiles.Count} arquivos.");

    foreach (var relativeFile in modifiedFiles)
    {
        var sourceFile = Path.Combine(sourceDir, relativeFile);

        if (!File.Exists(sourceFile))
        {
            Console.WriteLine($"Ignorado (não existe mais): {relativeFile}");
            continue;
        }

        var targetFile = Path.Combine(targetDir, relativeFile);

        Directory.CreateDirectory(Path.GetDirectoryName(targetFile)!);
        File.Copy(sourceFile, targetFile, true);

        Console.WriteLine($"Copiado: {relativeFile}");
    }

    Console.WriteLine();
    Console.WriteLine("Concluído! Arquivos do último commit copiados mantendo a estrutura de pastas.");
}

static void Pause()
{
    Console.WriteLine();
    Console.WriteLine("Pressione ENTER para continuar...");
    Console.ReadLine();
}

/// <summary>
/// Implementação simples de pattern matching estilo -like do PowerShell.
/// Suporta * e ?.
/// </summary>
static class StringLikeExtensions
{
    public static bool Like(this string text, string pattern)
    {
        if (string.IsNullOrEmpty(pattern)) return text == pattern;

        var regexPattern = "^" + Regex.Escape(pattern)
            .Replace(@"\*", ".*")
            .Replace(@"\?", ".") + "$";

        return Regex.IsMatch(text, regexPattern, RegexOptions.IgnoreCase);
    }
}
