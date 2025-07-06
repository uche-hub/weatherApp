import 'package:flutter/material.dart';

class AppColor {
  // Primary colors (weather-inspired)
  static const Color primaryBlue = Color(0xFF4FC3F7); // Lighter, softer blue for clear sky
  static const Color primaryDarkBlue = Color(0xFF0277BD); // Deep blue for night sky
  static const Color accentYellow = Color(0xFFFFE082); // Softer yellow for sunny weather
  static const Color accentOrange = Color(0xFFFFB300); // Warm amber for warm weather

  // Background colors
  static const Color lightBackground = Color(0xFFF5F7FA); // Unchanged for light mode
  static const Color darkBackground = Color(0xFF121212); // Deeper black for dark mode
  static const Color cardBackgroundLight = Color(0xFFFFFFFF); // Unchanged
  static const Color cardBackgroundDark = Color(0xFF2A2A2A); // Darker gray for cards

  // Text colors
  static const Color primaryTextLight = Color(0xFF212121); // Unchanged
  static const Color primaryTextDark = Color(0xFFE0E0E0); // Soft off-white for better contrast
  static const Color secondaryTextLight = Color(0xFF757575); // Unchanged
  static const Color secondaryTextDark = Color(0xFFB0BEC5); // Light gray (unchanged, sufficient contrast)

  // Error and status colors
  static const Color errorRed = Color(0xFFEF5350); // Softer red for errors
  static const Color successGreen = Color(0xFF4CAF50); // Brighter green for success

  // Gradient for weather cards or backgrounds
  static const LinearGradient weatherGradient = LinearGradient(
    colors: [primaryBlue, primaryDarkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-based color schemes
  static ThemeData get lightTheme => ThemeData(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: lightBackground,
        cardColor: cardBackgroundLight,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: primaryTextLight,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: primaryTextLight),
          bodyMedium: TextStyle(color: secondaryTextLight),
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryBlue,
          secondary: accentYellow,
          error: errorRed,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: primaryDarkBlue,
        scaffoldBackgroundColor: darkBackground,
        cardColor: cardBackgroundDark,
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: primaryTextDark, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: primaryTextDark),
          bodyMedium: TextStyle(color: secondaryTextDark),
        ),
        colorScheme: const ColorScheme.dark(
          primary: primaryDarkBlue,
          secondary: accentOrange,
          error: errorRed,
        ),
      );

  static ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}