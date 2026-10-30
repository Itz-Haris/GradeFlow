import 'package:flutter/material.dart';

/// AppTheme defines the visual identity for GradeFlow — Student Academic Performance Tracker.
///
/// Designed with a modern, academic dashboard aesthetic:
/// - Primary: Deep Navy Blue
/// - Secondary: Electric Blue
/// - Accent: Cyan
/// - Background: Light Blue-Grey
/// - Cards: White with 20px rounded corners & soft shadows
/// - Status Colors: Green (Positive) & Orange (Warning)
class AppTheme {
  // Brand Colors
  static const Color primaryNavy = Color(0xFF0F172A); // Deep Navy Blue
  static const Color primaryNavyDark = Color(0xFF0A0F1D);
  static const Color secondaryElectric = Color(0xFF2563EB); // Electric Blue
  static const Color secondaryElectricLight = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan Accent
  static const Color accentCyanLight = Color(0xFF22D3EE);
  
  // Background & Surface
  static const Color backgroundLight = Color(0xFFF1F5F9); // Light Blue-Grey
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Clean White Cards
  static const Color cardSubtle = Color(0xFFF8FAFC);
  
  // Status & Indicator Colors
  static const Color positiveGreen = Color(0xFF10B981); // Emerald Green
  static const Color positiveGreenBg = Color(0xFFD1FAE5);
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Orange
  static const Color warningOrangeBg = Color(0xFFFEF3C7);
  static const Color criticalRed = Color(0xFFEF4444); // Crimson
  static const Color criticalRedBg = Color(0xFFFEE2E2);
  static const Color neutralGrey = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);

  // Corner Radii (Specified between 18–22px)
  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 14.0;

  // Soft Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardHoverShadow => [
        BoxShadow(
          color: const Color(0xFF2563EB).withOpacity(0.12),
          blurRadius: 22,
          offset: const Offset(0, 8),
          spreadRadius: 1,
        ),
      ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNavy, secondaryElectric],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricCyanGradient = LinearGradient(
    colors: [secondaryElectric, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Light Theme Configuration (Material Design 3)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: secondaryElectric,
        onPrimary: surfaceWhite,
        secondary: accentCyan,
        onSecondary: surfaceWhite,
        error: criticalRed,
        onError: surfaceWhite,
        surface: surfaceWhite,
        onSurface: primaryNavy,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryNavy),
        titleTextStyle: TextStyle(
          color: primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderGrey, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: secondaryElectric,
          foregroundColor: surfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryElectric,
          side: const BorderSide(color: secondaryElectric, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: secondaryElectric, width: 2),
        ),
        hintStyle: const TextStyle(
          color: neutralGrey,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        elevation: 12,
        selectedItemColor: secondaryElectric,
        unselectedItemColor: neutralGrey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
