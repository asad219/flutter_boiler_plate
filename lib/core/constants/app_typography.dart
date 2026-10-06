import 'package:flutter/material.dart';

/// Font names. Each one must match a `family:` in pubspec.yaml.
class AppFonts {
  AppFonts._();

  static const String proximaNova = 'ProximaNova';
  static const String dubai = 'DubaiFont';
}

class AppTypography {
  AppTypography._();

  /// Font for the whole app. Change this to switch fonts.
  static const String fontFamily = AppFonts.proximaNova;

  /// Font per language code. Other languages use [fontFamily].
  static const Map<String, String> fontFamilyByLanguage = {
    'ar': AppFonts.dubai,
  };

  /// Used when the main font doesn't have a character, e.g. Arabic text in
  /// the English UI.
  static const List<String> fontFamilyFallback = [AppFonts.dubai];

  static String fontFamilyFor(Locale locale) =>
      fontFamilyByLanguage[locale.languageCode] ?? fontFamily;

  /// If a weight has no font file, the closest one is used.
  static TextTheme textTheme(Color color) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: color),
      bodyMedium: TextStyle(fontSize: 14, color: color),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
