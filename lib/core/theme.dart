import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0F5C50);
  static const primarySoft = Color(0xFFE3F1ED);
  static const bg = Color(0xFFE9ECE8);
  static const line = Color(0xFFDDE3DF);
  static const muted = Color(0xFF5E6B66);
  static const danger = Color(0xFFB3372F);
  static const ink = Color(0xFF17231F);
}

ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: GoogleFonts.figtreeTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
