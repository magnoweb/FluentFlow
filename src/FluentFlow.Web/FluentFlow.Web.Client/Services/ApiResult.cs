namespace FluentFlow.Web.Client.Services;

public class ApiResult
{
    public bool Success { get; private init; }
    public string Error { get; private init; } = "";

    public static ApiResult Ok()           => new() { Success = true };
    public static ApiResult Fail(string e) => new() { Success = false, Error = e };
}

public class ApiResult<T>
{
    public bool Success { get; private init; }
    public T?   Value   { get; private init; }
    public string Error { get; private init; } = "";

    public static ApiResult<T> Ok(T value)     => new() { Success = true,  Value = value };
    public static ApiResult<T> Fail(string e)  => new() { Success = false, Error = e };
}