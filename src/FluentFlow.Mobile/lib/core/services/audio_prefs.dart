import 'package:shared_preferences/shared_preferences.dart';

/// Preferências de áudio guardadas localmente (funcionam offline).
class AudioPrefs {
  AudioPrefs._();

  static const List<double> speedOptions = [0.75, 0.9, 1.0, 1.1, 1.25];

  static const String _studyRateKey = 'ff_study_rate';
  static const String _deckRepeatPrefix = 'ff_deck_repeat_';

  /// 0.75 → "0.75×", 1.0 → "1×"
  static String formatRate(double rate) =>
      '${rate.toString().replaceAll(RegExp(r'\.0$'), '')}×';

  // ── Velocidade dos cards ─────────────────────────────────────────────────────
  static Future<double> getStudyRate() async {
    final prefs = await SharedPreferences.getInstance();
    final rate = prefs.getDouble(_studyRateKey) ?? 1.0;
    return speedOptions.contains(rate) ? rate : 1.0;
  }

  static Future<void> setStudyRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_studyRateKey, rate);
  }

  // ── Repetições do áudio por deck (configuradas na web) ───────────────────────
  static Future<int> getDeckRepeatCount(String deckId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt('$_deckRepeatPrefix$deckId') ?? 1).clamp(1, 10).toInt();
  }

  static Future<void> setDeckRepeatCount(String deckId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_deckRepeatPrefix$deckId', count.clamp(1, 10).toInt());
  }
}
