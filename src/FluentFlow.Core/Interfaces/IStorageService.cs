namespace FluentFlow.Core.Interfaces;

public interface IStorageService
{
    Task<string> SaveAsync(Stream content, string fileName, string folder);
    Task<Stream> ReadAsync(string path);
    Task DeleteAsync(string path);
    Task<bool> ExistsAsync(string path);
}