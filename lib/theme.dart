import 'package:flutter/material.dart';

/// Haifora Theme
/// Defines both Light and Dark themes for the app.
/// Playful, social, and warm visual language.

class HaiforaTheme {
  // Brand Colors
  static const Color darkNavy = Color(0xFF2C3A47);
  static const Color tealBlue = Color(0xFF5CA4A9);
  static const Color coral = Color(0xFFF18F01);
  static const Color warmYellow = Color(0xFFF6AE2D);
  static const Color background = Color(0xFFFDFBF7);
  static const Color darkBackground = Color(0xFF1E1E1E);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: darkNavy,
    colorScheme: const ColorScheme.light(
      primary: darkNavy,
      secondary: tealBlue,
      tertiary: coral,
      surface: background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkNavy,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: darkNavy,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: darkNavy,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
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
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkNavy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  // Dark Theme
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
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: Colors.white70,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
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
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF141414),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
