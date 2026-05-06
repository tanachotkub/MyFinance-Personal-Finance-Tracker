import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color incomeColor  = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFFF6B6B);

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.promptTextTheme(base).copyWith(
      displayLarge:  GoogleFonts.prompt(fontSize: 32, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.prompt(fontSize: 28, fontWeight: FontWeight.w600),
      titleLarge:    GoogleFonts.prompt(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium:   GoogleFonts.prompt(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge:     GoogleFonts.prompt(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium:    GoogleFonts.prompt(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall:     GoogleFonts.prompt(fontSize: 12, fontWeight: FontWeight.w300),
      labelLarge:    GoogleFonts.prompt(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      titleTextStyle: GoogleFonts.prompt(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF16213E),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: const Color(0xFF16213E),
      titleTextStyle: GoogleFonts.prompt(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}