import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    const baseColor = AppColors.background;
    const surface = AppColors.surface;
    const primary = AppColors.primary;
    const secondary = Color(0xFF7C3AED); // Purple accent

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      background: baseColor,
      surface: surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      // Make the background image provided by outer builder visible
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
      textTheme: Typography.blackCupertino.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w700),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w800),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFFE9EBF0),
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black54,
        textColor: AppColors.textPrimary,
        selectedColor: primary,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        // Keep sidebar background color, change to Colors.transparent if fully transparent is needed
        backgroundColor: baseColor,
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
        unselectedIconTheme: IconThemeData(color: Colors.black45),
        unselectedLabelTextStyle: TextStyle(color: Colors.black54),
        groupAlignment: -0.8,
      ),
      // Primary CTA: FilledButton (high weight)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: const StadiumBorder(),
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      // Secondary: Outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: const StadiumBorder(),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
      ),
      // Tertiary: Tonal (weakened)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5E7EB),
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData get darkTheme {
    const base = Color(0xFF0F1115);
    const surface = Color(0xFF151922);
    const primary = AppColors.primary;
    const secondary = Color(0xFF7C3AED);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      background: base,
      surface: surface,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: Typography.whiteCupertino,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2430),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
} 