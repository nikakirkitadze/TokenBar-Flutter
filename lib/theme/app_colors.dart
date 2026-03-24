import 'package:flutter/material.dart';

class AppColors {
  // Dark theme
  static const darkBackground = Color(0xFF1A1A1E);
  static const darkSurface = Color(0xFF26262B);
  static const darkSurfaceElevated = Color(0xFF2F2F35);
  static const darkDivider = Color(0xFF38383E);
  static const darkInputBackground = Color(0xFF2A2A30);
  static const darkTextPrimary = Color(0xFFF0F0F3);
  static const darkTextSecondary = Color(0xFF9E9EA6);
  static const darkTextTertiary = Color(0xFF6C6C74);

  // Light theme
  static const lightBackground = Color(0xFFF8F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF2F2F5);
  static const lightDivider = Color(0xFFE0E0E4);
  static const lightInputBackground = Color(0xFFF0F0F3);
  static const lightTextPrimary = Color(0xFF1A1A1E);
  static const lightTextSecondary = Color(0xFF6C6C74);
  static const lightTextTertiary = Color(0xFF9E9EA6);

  // Semantic (shared)
  static const accent = Color(0xFF34D399);
  static const accentLight = Color(0xFF6EE7B7);
  static const accentDark = Color(0xFF059669);
  static const warning = Color(0xFFFBBF24);
  static const warningDark = Color(0xFFD97706);
  static const danger = Color(0xFFF87171);
  static const dangerDark = Color(0xFFDC2626);
  static const info = Color(0xFF60A5FA);
  static const infoDark = Color(0xFF2563EB);
}

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkSurface,
      primary: AppColors.accent,
      error: AppColors.danger,
    ),
    cardColor: AppColors.darkSurface,
    dividerColor: AppColors.darkDivider,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
      bodySmall: TextStyle(color: AppColors.darkTextSecondary),
      titleLarge: TextStyle(color: AppColors.darkTextPrimary),
      titleMedium: TextStyle(color: AppColors.darkTextPrimary),
      titleSmall: TextStyle(color: AppColors.darkTextSecondary),
      labelLarge: TextStyle(color: AppColors.darkTextPrimary),
      labelMedium: TextStyle(color: AppColors.darkTextSecondary),
      labelSmall: TextStyle(color: AppColors.darkTextTertiary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkDivider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightSurface,
      primary: AppColors.accentDark,
      error: AppColors.dangerDark,
    ),
    cardColor: AppColors.lightSurface,
    dividerColor: AppColors.lightDivider,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
      bodySmall: TextStyle(color: AppColors.lightTextSecondary),
      titleLarge: TextStyle(color: AppColors.lightTextPrimary),
      titleMedium: TextStyle(color: AppColors.lightTextPrimary),
      titleSmall: TextStyle(color: AppColors.lightTextSecondary),
      labelLarge: TextStyle(color: AppColors.lightTextPrimary),
      labelMedium: TextStyle(color: AppColors.lightTextSecondary),
      labelSmall: TextStyle(color: AppColors.lightTextTertiary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.lightDivider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
