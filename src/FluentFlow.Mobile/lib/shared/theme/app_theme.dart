import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary   = Color(0xFF594AE2);
  static const Color secondary = Color(0xFF7B6EF5);
  static const Color surface   = Color(0xFFF8F7FF);
  static const Color error     = Color(0xFF7A2E10);

  static ThemeData get light => ThemeData(
    useMaterial3:            true,
    colorSchemeSeed:         primary,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation:       1,
      centerTitle:     false,
    ),
    cardTheme: CardThemeData(              // ← CardThemeData em vez de CardTheme
      elevation: 2,
      shape:     RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
    ),
  );
}