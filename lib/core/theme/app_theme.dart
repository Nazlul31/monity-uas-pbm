import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // === Monity Color Palette (sesuai Figma) ===
  static const Color primaryColor = Color(0xFF2DC7A2);      // Hijau Teal utama
  static const Color primaryDark  = Color(0xFF1FA88A);      // Hover/Pressed state
  static const Color backgroundColor = Color(0xFFF5F7FA);  // Background light
  static const Color surfaceColor = Colors.white;
  static const Color darkBg = Color(0xFF1C2A3A);            // Splash background

  // Semantic colors (sesuai PROJECT_CONTEXT.md)
  static const Color incomeColor  = Color(0xFF2DC7A2);      // Pemasukan — Hijau
  static const Color expenseColor = Color(0xFFFF6B6B);      // Pengeluaran — Merah

  // Text colors
  static const Color textPrimary   = Color(0xFF1C2A3A);
  static const Color textSecondary = Color(0xFF8A94A6);
  static const Color textOnPrimary = Colors.white;

  // Card & Border
  static const Color cardColor     = Colors.white;
  static const Color borderColor   = Color(0xFFE8ECF0);

  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        error: expenseColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 13,
        ),
        labelLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
          textStyle:
              GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
    );
  }
}
