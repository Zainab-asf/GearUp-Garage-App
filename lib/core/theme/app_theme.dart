import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF2E9DB);
  static const Color surface = Color(0xFFF8F1E6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF2E4A73);
  static const Color secondary = Color(0xFFD07B42);
  static const Color accent = Color(0xFFF2C57A);
  static const Color error = Color(0xFFD96A5C);
  static const Color success = Color(0xFF3F9D7A);
  static const Color white = Color(0xFFFDF8F2);
  static const Color textPrimary = Color(0xFF2B2A28);
  static const Color textSecondary = Color(0xFF6E6258);
  static const Color buttonPrimary = Color(0xFF2E4A73);
  static const Color buttonText = Color(0xFFFDF8F2);
  static const Color inputFill = Color(0xFFFFF8EE);
  static const Color inputIcon = Color(0xFF2E4A73);
  static const Color inputBorder = Color(0xFFD8CFC4);
  static const Color inputFocused = Color(0xFF2E4A73);
  static const Color shadowSoft = Color(0x1F2B2A28);
  static const Color shadowStrong = Color(0x332B2A28);

  static LinearGradient get pageGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6EFE4), Color(0xFFF1E6D6), Color(0xFFEFE3D1)],
  );

  static ThemeData get gradientTheme {
    final baseText = GoogleFonts.quicksandTextTheme();
    final displayText = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        surfaceVariant: card,
        outline: inputBorder,
        onPrimary: buttonText,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        error: error,
        onError: white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 6,
        shadowColor: const Color(0x1F2E2A25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPrimary,
          foregroundColor: buttonText,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputFocused, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: primary),
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: inputIcon,
        suffixIconColor: inputIcon,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      textTheme: baseText.copyWith(
        displayLarge: displayText.displayLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        displayMedium: displayText.displayMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        displaySmall: displayText.displaySmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        headlineLarge: displayText.headlineLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        headlineMedium: displayText.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        headlineSmall: displayText.headlineSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseText.titleSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(color: textSecondary),
        bodyMedium: baseText.bodyMedium?.copyWith(color: textSecondary),
        bodySmall: baseText.bodySmall?.copyWith(color: textSecondary),
        labelLarge: baseText.labelLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: baseText.labelMedium?.copyWith(color: textSecondary),
        labelSmall: baseText.labelSmall?.copyWith(color: textSecondary),
      ),
      iconTheme: const IconThemeData(color: primary, size: 22),
      dividerTheme: const DividerThemeData(color: inputBorder, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: buttonText,
        elevation: 4,
        shape: CircleBorder(),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
        scrimColor: Color(0x662B2A28),
        elevation: 12,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withOpacity(0.12),
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: inputBorder),
        ),
      ),
    );
  }
}
