import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFF28C38),
        surface: Colors.white,
        onSurface: Color(0xFF2C3338),
      ),
      textTheme: GoogleFonts.kanitTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFF28C38)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2C3338),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Kanit',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF28C38),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFF28C38).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Kanit',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF28C38), width: 1.5),
        ),
      ),
    );
  }
}
