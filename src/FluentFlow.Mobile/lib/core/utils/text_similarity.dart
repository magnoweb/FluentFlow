/// Similaridade de Levenshtein normalizada — 0.0 (diferente) a 1.0 (idêntico)
class TextSimilarity {
  TextSimilarity._();

  static double calculate(String a, String b) {
    final sa = a.trim().toLowerCase();
    final sb = b.trim().toLowerCase();

    if (sa == sb) return 1.0;
    if (sa.isEmpty || sb.isEmpty) return 0.0;

    final maxLen = sa.length > sb.length ? sa.length : sb.length;
    final dist = _levenshtein(sa, sb);
    return double.parse((1.0 - dist / maxLen).toStringAsFixed(4));
  }

  static int _levenshtein(String a, String b) {
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }
}
