import 'package:flutter/material.dart';

import 'app_colors.dart';

class Styles {
  static ThemeData themeData() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF244638),
        primary: const Color(0xFF244638),
      ),
      appBarTheme: const AppBarTheme(
        toolbarHeight: 52,
        backgroundColor: AppColors.lightScaffoldColor,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF244638),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE3E7E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE3E7E0)),
        ),
      ),
      scaffoldBackgroundColor: AppColors.lightScaffoldColor,
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFEDF3EC),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, color: AppColors.lightPrimary),
        ),
      ),
      useMaterial3: true,
    );
  }
}
