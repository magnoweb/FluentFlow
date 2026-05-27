namespace FluentFlow.Core.Common;

public static class TextSimilarity
{
    /// <summary>
    /// Similaridade de Levenshtein normalizada — retorna 0.0 (diferente) a 1.0 (idêntico).
    /// Compara sem distinção de maiúsculas/minúsculas e sem espaços extra.
    /// </summary>
    public static double Calculate(string a, string b)
    {
        a = a.Trim().ToLowerInvariant();
        b = b.Trim().ToLowerInvariant();

        if (a == b) return 1.0;
        if (string.IsNullOrEmpty(a) || string.IsNullOrEmpty(b)) return 0.0;

        int maxLen = Math.Max(a.Length, b.Length);
        int dist   = LevenshteinDistance(a, b);
        return Math.Round(1.0 - (double)dist / maxLen, 4);
    }

    private static int LevenshteinDistance(string a, string b)
    {
        // Optimização: usar apenas duas linhas em vez de matriz completa
        var prev = Enumerable.Range(0, b.Length + 1).ToArray();
        var curr = new int[b.Length + 1];

        for (int i = 1; i <= a.Length; i++)
        {
            curr[0] = i;
            for (int j = 1; j <= b.Length; j++)
            {
                int cost = a[i - 1] == b[j - 1] ? 0 : 1;
                curr[j]  = Math.Min(
                    Math.Min(curr[j - 1] + 1, prev[j] + 1),
                    prev[j - 1] + cost);
            }
            Array.Copy(curr, prev, curr.Length);
        }

        return prev[b.Length];
    }
}