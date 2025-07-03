import 'package:flutter/material.dart';

/// A class that defines the color theme for the weather app.
/// Provides a consistent set of colors for UI elements, supporting both light and dark modes.
class AppColor {
  // Primary colors inspired by weather elements
  static const Color primaryBlue = Color(0xFF0288D1); // Blue for clear sky
  static const Color primaryDarkBlue = Color(
    0xFF01579B,
  ); // Darker blue for night sky
  static const Color accentYellow = Color(
    0xFFFFCA28,
  ); // Yellow for sunny weather
  static const Color accentOrange = Color(
    0xFFFFA726,
  ); // Orange for warm weather

  // Background colors
  static const Color lightBackground = Color(
    0xFFF5F7FA,
  ); // Light grayish-blue for light mode
  static const Color darkBackground = Color(
    0xFF212121,
  ); // Dark gray for dark mode
  static const Color cardBackgroundLight = Color(
    0xFFFFFFFF,
  ); // White for cards in light mode
  static const Color cardBackgroundDark = Color(
    0xFF424242,
  ); // Dark gray for cards in dark mode

  // Text colors
  static const Color primaryTextLight = Color(
    0xFF212121,
  ); // Dark gray for text in light mode
  static const Color primaryTextDark = Color(
    0xFFFFFFFF,
  ); // White for text in dark mode
  static const Color secondaryTextLight = Color(
    0xFF757575,
  ); // Lighter gray for secondary text
  static const Color secondaryTextDark = Color(
    0xFFB0BEC5,
  ); // Light gray for secondary text in dark mode

  // Error and status colors
  static const Color errorRed = Color(0xFFD32F2F); // Red for error messages
  static const Color successGreen = Color(
    0xFF388E3C,
  ); // Green for success states

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

  /// Returns the appropriate theme based on the device's brightness.
  static ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}
