import 'package:flutter/material.dart';

abstract final class AppColors {
  static const yellow = Color(0xFFFFC21A);
  static const ink = Color(0xFF181818);
  static const muted = Color(0xFF686868);
  static const canvas = Color(0xFFF7F7F7);
  static const border = Color(0xFFECECEC);
  static const paleYellow = Color(0xFFFFF7DF);
  static const paleBlue = Color(0xFFEEF3FF);
  static const blue = Color(0xFF3469CA);
  static const paleGreen = Color(0xFFEAF6EF);
  static const green = Color(0xFF2D7A4E);
  static const paleOrange = Color(0xFFFFF0E4);
  static const orange = Color(0xFFAC601F);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colors =
        ColorScheme.fromSeed(
          seedColor: AppColors.yellow,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.yellow,
          onPrimary: AppColors.ink,
          secondary: AppColors.ink,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.muted,
          outlineVariant: AppColors.border,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: colors,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15, height: 1.7),
        bodyMedium: TextStyle(fontSize: 13, height: 1.6),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.yellow,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        errorMaxLines: 3,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    );
  }
}
