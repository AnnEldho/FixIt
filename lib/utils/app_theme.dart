import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // FIXIT BRAND COLORS
  // =========================

  static const Color primary = Color(0xFF19C37D);

  static const Color background = Color(0xFF08111F);

  static const Color surface = Color(0xFF111C2D);

  static const Color surfaceLight = Color(0xFF172438);

  static const Color textPrimary = Color(0xFFFFFFFF);

  static const Color textSecondary = Color(0xFF9AA7B8);

  static const Color textMuted = Color(0xFF667386);

  static const Color divider = Color(0xFF263448);

  static const Color warning = Color(0xFFF59E0B);

  static const Color error = Color(0xFFEF4444);

  static const Color success = Color(0xFF19C37D);

  // =========================
  // MAIN APP THEME
  // =========================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: surface,
      error: error,
      onPrimary: background,
      onSecondary: background,
      onSurface: textPrimary,
      onError: Colors.white,
    ),

    // =========================
    // TEXT
    // =========================

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),

      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),

      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
      ),

      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),

      bodySmall: TextStyle(
        color: textMuted,
        fontSize: 12,
      ),
    ),

    // =========================
    // INPUT FIELDS
    // =========================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),

      hintStyle: const TextStyle(
        color: textMuted,
      ),

      prefixIconColor: textSecondary,

      suffixIconColor: textSecondary,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: error,
          width: 1.2,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: error,
          width: 1.5,
        ),
      ),
    ),

    // =========================
    // BUTTONS
    // =========================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,

        foregroundColor: background,

        elevation: 0,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // =========================
    // OUTLINED BUTTONS
    // =========================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        side: const BorderSide(
          color: primary,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // =========================
    // TEXT BUTTONS
    // =========================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    ),

    // =========================
    // CARDS
    // =========================

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // =========================
    // APP BAR
    // =========================

    appBarTheme: const AppBarTheme(
      backgroundColor: background,

      foregroundColor: textPrimary,

      elevation: 0,

      centerTitle: false,
    ),

    // =========================
    // DIVIDERS
    // =========================

    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
    ),
  );
}