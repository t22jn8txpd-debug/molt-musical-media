import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Molt brand colors (from the original foundation site) ──
class MoltColors {
  MoltColors._();

  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const blue = Color(0xFF3B82F6);
  static const dark = Color(0xFF0F172A);
  static const darker = Color(0xFF020617);
  static const surface = Color(0xFF1E293B);
  static const surfaceLight = Color(0xFF334155);
  static const textMuted = Color(0xFF94A3B8);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);

  static const purplePinkGradient = LinearGradient(
    colors: [purple, pink],
  );

  static const purpleBlueGradient = LinearGradient(
    colors: [purple, blue],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darker, dark, Color(0xFF0F1629)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF162032)],
  );
}

ThemeData buildMoltTheme() {
  final textTheme = GoogleFonts.interTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: MoltColors.purple,
      onPrimary: Colors.white,
      secondary: MoltColors.pink,
      onSecondary: Colors.white,
      error: MoltColors.error,
      onError: Colors.white,
      surface: MoltColors.surface,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: MoltColors.darker,
    cardColor: MoltColors.surface,
    textTheme: textTheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: MoltColors.darker.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MoltColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MoltColors.purple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: MoltColors.textMuted),
      hintStyle: const TextStyle(color: MoltColors.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MoltColors.purple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: MoltColors.purple.withValues(alpha: 0.15),
      selectedColor: MoltColors.purple.withValues(alpha: 0.3),
      labelStyle: textTheme.bodySmall?.copyWith(color: MoltColors.purple),
      side: BorderSide(color: MoltColors.purple.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MoltColors.darker,
      selectedItemColor: MoltColors.purple,
      unselectedItemColor: MoltColors.textMuted,
      type: BottomNavigationBarType.fixed,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: MoltColors.dark,
      selectedIconTheme: IconThemeData(color: MoltColors.purple),
      unselectedIconTheme: IconThemeData(color: MoltColors.textMuted),
      selectedLabelTextStyle: TextStyle(color: MoltColors.purple, fontWeight: FontWeight.w600),
    ),
    dividerColor: MoltColors.purple.withValues(alpha: 0.15),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MoltColors.surface,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
