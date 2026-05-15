import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurpleDark,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
        onSurface: Colors.white,
        primary: AppColors.primaryPurpleDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}
