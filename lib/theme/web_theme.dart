// web_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'web_colors.dart';

class WebTheme {
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: WebColors.lightBg,
      primaryColor: WebColors.primary,

      colorScheme: const ColorScheme.light(
        primary: WebColors.primary,
        secondary: WebColors.secondary,
        surface: WebColors.lightBgSoft,
        background: WebColors.lightBg,
        onSurface: WebColors.lightText,
        onBackground: WebColors.lightText,
      ),

      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: WebColors.lightText,
        displayColor: WebColors.lightText,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: WebColors.lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: WebColors.lightBgSoft,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
      ),

      dividerColor: WebColors.lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: WebColors.darkBg,
      primaryColor: WebColors.primary,

      colorScheme: const ColorScheme.dark(
        primary: WebColors.primary,
        secondary: WebColors.secondary,
        surface: WebColors.darkBgSoft,
        background: WebColors.darkBg,
        onSurface: WebColors.darkText,
        onBackground: WebColors.darkText,
      ),

      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: WebColors.darkText,
        displayColor: WebColors.darkText,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: WebColors.darkBgSoft,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.4),
      ),

      dividerColor: WebColors.darkBorder,
    );
  }
}
