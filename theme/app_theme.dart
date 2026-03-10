import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- 1. Light Palette ---
  static const Color emeraldPrimary = Color(0xFF10B981);
  static const Color emeraldDark    = Color(0xFF064E3B);
  static const Color emeraldLight   = Color(0xFFD1FAE5);
  static const Color surfaceWhite   = Color(0xFFFFFFFF);
  static const Color quartzGrey     = Color(0xFFF9FAFB);
  static const Color critical       = Color(0xFFEF4444); // Error red

  // --- 2. Dark Palette ---
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface    = Color(0xFF1F2937);
  static const Color darkPrimary    = Color(0xFF34D399);
  static const Color darkText       = Color(0xFFF9FAFB);

  // --- 3. Light Theme ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surfaceWhite,
      primaryColor: emeraldPrimary,
      colorScheme: const ColorScheme.light(
        primary: emeraldPrimary,
        secondary: emeraldDark,
        surface: surfaceWhite,
        onSurface: emeraldDark,
        error: critical,
      ),
      textTheme: _buildTextTheme(emeraldDark),
      // NOTE: Use CardThemeData if on very new Flutter, otherwise CardTheme
      cardTheme: CardThemeData(
        color: quartzGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: quartzGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  // --- 4. Dark Theme ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: emeraldLight,
        surface: darkSurface,
        onSurface: darkText,
        error: critical,
      ),
      textTheme: _buildTextTheme(darkText),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      iconTheme: const IconThemeData(color: darkText),
    );
  }

  static TextTheme _buildTextTheme(Color color) {
    return GoogleFonts.interTextTheme().copyWith(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: -1.0, color: color),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: color),
      bodyLarge: TextStyle(fontSize: 16, color: color.withOpacity(0.9)),
      bodyMedium: TextStyle(fontSize: 14, color: color.withOpacity(0.7)),
    );
  }
}