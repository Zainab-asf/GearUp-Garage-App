import 'package:flutter/material.dart';

class AppTheme {
  // Palette:
  // Red:      #BC4749 (main action buttons, input icons, error)
  // Mint:     #F1FAEE (main text, white)
  // LightBlue:#A8DADC (secondary icons/text)
  // Navy:     #1D3557 (background, card)
  // InputBG:  #E0E1DD (input fields)

  static const Color background = Color(0xFF1D3557); // navy background
  static const Color card = Color(0xFF1D3557); // card/navy
  static const Color primary = Color(0xFF1D3557); // navy
  static const Color secondary = Color(0xFFA8DADC); // light blue
  static const Color accent = Color(0xFFA8DADC); // light blue
  static const Color error = Color(0xFFBC4749); // red (for error/highlight)
  static const Color white = Color(0xFFF1FAEE); // white text
  static const Color textPrimary = Color(0xFFF1FAEE); // white for main text
  static const Color textSecondary = Color(
    0xFFA8DADC,
  ); // light blue for secondary text
  static const Color buttonPrimary = Color(0xFFBC4749); // red for main buttons
  static const Color buttonText = Color(0xFFF1FAEE); // white for button text
  static const Color inputFill = Color(0xFFE0E1DD); // light for input fields
  static const Color inputIcon = Color(0xFFBC4749); // red for input icons
  static const Color inputBorder = Color(0xFF1D3557); // navy border
  static const Color inputFocused = Color(0xFFA8DADC); // light blue focus

  static ThemeData get gradientTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: accent,
        onPrimary: buttonText,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        error: error,
        onError: buttonText,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 4,
        shadowColor: primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPrimary,
          foregroundColor: buttonText,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: inputFocused, width: 2),
        ),
        labelStyle: TextStyle(color: primary),
        floatingLabelStyle: TextStyle(color: primary),
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: accent,
        suffixIconColor: accent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textSecondary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textSecondary),
      ),
      iconTheme: const IconThemeData(color: accent, size: 24),
      dividerTheme: const DividerThemeData(color: accent, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: buttonText,
        elevation: 6,
        shape: CircleBorder(),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
        scrimColor: Colors.black54,
        elevation: 16,
      ),
    );
  }
}
