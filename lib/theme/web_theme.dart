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
      ),
      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: WebColors.lightText,
        displayColor: WebColors.lightText,
      ),
      cardTheme: CardThemeData(
        color: WebColors.lightBgSoft,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
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
      ),
      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: WebColors.darkText,
        displayColor: WebColors.darkText,
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
