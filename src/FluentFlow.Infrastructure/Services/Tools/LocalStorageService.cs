using FluentFlow.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace FluentFlow.Infrastructure.Services.Tools;

public class LocalStorageService(IConfiguration config, ILogger<LocalStorageService> logger) : IStorageService
{
    private string RootPath => config["Storage:LocalPath"] ?? Path.Combine(Directory.GetCurrentDirectory(), "App_Data", "Uploads");

    public async Task<string> SaveAsync(Stream content, string fileName, string folder)
    {
        var dir = Path.Combine(RootPath, folder);
        Directory.CreateDirectory(dir);

        var uniqueName = $"{Guid.NewGuid()}_{fileName}";
        var fullPath   = Path.Combine(dir, uniqueName);

        await using var fs = File.Create(fullPath);
        await content.CopyToAsync(fs);

        logger.LogInformation("File saved: {Path}", fullPath);
        return Path.Combine(folder, uniqueName).Replace('\\', '/');
    }

    public Task<Stream> ReadAsync(string path)
    {
        var fullPath = Path.Combine(RootPath, path);
        if (!File.Exists(fullPath))
            throw new FileNotFoundException("File not found.", fullPath);

        return Task.FromResult<Stream>(File.OpenRead(fullPath));
    }

    public Task DeleteAsync(string path)
    {
        var fullPath = Path.Combine(RootPath, path);
        if (File.Exists(fullPath)) File.Delete(fullPath);
        return Task.CompletedTask;
    }

    public Task<bool> ExistsAsync(string path) =>
        Task.FromResult(File.Exists(Path.Combine(RootPath, path)));
}