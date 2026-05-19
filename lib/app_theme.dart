import 'package:flutter/material.dart';

class AppColors {
  // Define your Sage & Cream palette here
  static const Color sageGreen = Color(0xFF9CAF88); // The soft green from your image
  static const Color creamBackground = Color(0xFFF5F5F1); // Light cream surface
  static const Color deepCharcoal = Color(0xFF1A1A1A); // The dark panel color
  static const Color accentSage = Color(0xFFC2D3B3); // Lighter sage for hovers
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sageGreen,
      primary: AppColors.sageGreen,
      surface: AppColors.creamBackground,
      background: AppColors.creamBackground,
      onSurface: AppColors.deepCharcoal,
    ),
    // This makes all your TextFields look like the premium design
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.sageGreen.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.sageGreen, width: 2),
      ),
    ),
  );
}