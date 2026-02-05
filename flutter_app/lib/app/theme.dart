import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildMoltTheme() {
  const dark = Color(0xFF0F1115);
  const surface = Color(0xFF161A22);
  const primary = Color(0xFF4DD7C8);
  const secondary = Color(0xFFF0B45B);
  const accent = Color(0xFF90A7FF);

  final textTheme = GoogleFonts.dmSansTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: dark,
      secondary: secondary,
      onSecondary: dark,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: surface,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: dark,
    cardColor: surface,
    textTheme: textTheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: dark,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: accent.withValues(alpha: 0.25),
      labelStyle: textTheme.bodyMedium,
    ),
  );
}
