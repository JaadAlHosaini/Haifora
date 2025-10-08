import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Haifora Theme
/// Playful, social, and warm visual language.
/// Combines comic-inspired typography with friendly colors.

class HaiforaTheme {
  // 🎨 Brand Colors
  static const Color darkNavy = Color(0xFF2C3A47);
  static const Color tealBlue = Color(0xFF5CA4A9);
  static const Color coral = Color(0xFFF18F01);
  static const Color warmYellow = Color(0xFFF6AE2D);
  static const Color beigeBackground = Color(0xFFFAF3E0); // Warm beige tone
  static const Color darkBackground = Color(0xFF1E1B16); // Cozy dark brown

  // 🌞 LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: beigeBackground,
    primaryColor: coral,
    colorScheme: const ColorScheme.light(
      primary: coral,
      secondary: tealBlue,
      tertiary: warmYellow,
      surface: beigeBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkNavy,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: darkNavy,
      ),
      titleLarge: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: darkNavy,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: darkNavy,
      ),
      labelLarge: GoogleFonts.nunito(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: coral,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: coral,
      foregroundColor: Colors.white,
    ),
  );

  // 🌙 DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: warmYellow,
    colorScheme: const ColorScheme.dark(
      primary: warmYellow,
      secondary: tealBlue,
      tertiary: coral,
      surface: darkBackground,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.comicNeue(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: Colors.white70,
      ),
      labelLarge: GoogleFonts.nunito(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: warmYellow,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.comicNeue(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: warmYellow,
      foregroundColor: Colors.black,
    ),
  );
}
