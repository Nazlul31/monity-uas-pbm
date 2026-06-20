import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color constants
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color backgroundColor = Color(0xFFF8F9FA); // Neutral light grey
  static const Color surfaceColor = Colors.white;
  
  // Custom semantic colors
  static const Color incomeColor = Color(0xFF2E7D32); // Sukses / Pemasukan Green
  static const Color expenseColor = Color(0xFFD32F2F); // Kritis / Pengeluaran Red

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        error: expenseColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
