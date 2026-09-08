import 'package:flutter/material.dart';

class AppTheme {
  // Brand color tokens from UX-AND-DESIGN.md
  static const Color milk = Color(0xFFFFF9F0);
  static const Color cocoa = Color(0xFF3A241B);
  static const Color cream = Color(0xFFFFF1D6);
  static const Color rose = Color(0xFFD86773);
  static const Color saffron = Color(0xFFE8A23A);
  static const Color saffronDark = Color(0xFFCE8822);
  static const Color mint = Color(0xFF72B7A1);
  static const Color ink = Color(0xFF1E1B19);
  static const Color error = Color(0xFFB63A3A);
  static const Color muted = Color(0xFF8C7A70);
  static const Color border = Color(0xFFEADFCF);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: milk,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: saffron,
        onPrimary: cocoa,
        secondary: cocoa,
        onSecondary: milk,
        error: error,
        onError: Colors.white,
        surface: cream,
        onSurface: ink,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: milk,
        foregroundColor: cocoa,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: cocoa,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: saffron,
          foregroundColor: cocoa,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cocoa,
          side: const BorderSide(color: cocoa, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: saffron, width: 2),
        ),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        labelStyle: const TextStyle(color: cocoa, fontWeight: FontWeight.w500),
      ),
    );
  }

  static String formatPaise(int paise) {
    final rs = paise / 100;
    if (rs == rs.roundToDouble()) {
      return '₹${rs.toInt()}';
    }
    return '₹${rs.toStringAsFixed(2)}';
  }
}