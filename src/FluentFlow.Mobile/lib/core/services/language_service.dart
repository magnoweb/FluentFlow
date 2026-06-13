import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class LanguageService {
  static const _supported = [
    ('pt', '🇵🇹 Português'),
    ('en', '🇬🇧 English'),
    ('es', '🇪🇸 Español'),
    ('fr', '🇫🇷 Français')
  ];

  static List<(String code, String label)> get supported => _supported;

  static Future<void> setLanguage(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.language, code);

    // Notificar a app para reconstruir com novo locale
    // via callback ou state management
  }

  static Future<String> getCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.language) ?? 'pt';
  }
}
