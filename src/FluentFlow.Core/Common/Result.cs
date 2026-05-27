namespace FluentFlow.Core.Common;

public class Result<T>
{
    public bool IsSuccess { get; private set; }
    public T? Value { get; private set; }
    public string? Error { get; private set; }

    private Result() { }

    public static Result<T> Success(T value) =>
        new() { IsSuccess = true, Value = value };

    public static Result<T> Failure(string error) =>
        new() { IsSuccess = false, Error = error };
}

public class Result
{
    public bool IsSuccess { get; private set; }
    public string? Error { get; private set; }

    private Result() { }

    public static Result Success() =>
        new() { IsSuccess = true };

    public static Result Failure(string error) =>
        new() { IsSuccess = false, Error = error };
}

public record PagedResult<T>(
    IReadOnlyList<T> Items,
    int TotalCount,
    int Page,
    int PageSize
)
{
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasNext => Page < TotalPages;
    public bool HasPrev => Page > 1;
};