import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.primaryPurpleDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}