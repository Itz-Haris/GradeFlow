import 'package:flutter/material.dart';

/// AppTheme defines the visual identity for GradeFlow.
/// Supports both Light and Dark mode themes with full edge-to-edge support.
class AppTheme {
  // Brand Colors (Consistent in both modes)
  static const Color primaryNavy = Color(0xFF0F172A); // Deep Navy Blue
  static const Color primaryNavyDark = Color(0xFF0A0F1D);
  static const Color secondaryElectric = Color(0xFF2563EB); // Electric Blue
  static const Color secondaryElectricLight = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan Accent
  static const Color accentCyanLight = Color(0xFF22D3EE);
  
  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF1F5F9); // Light Blue-Grey
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Clean White Cards
  static const Color cardSubtle = Color(0xFFF8FAFC);
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0B111E); // Deep Obsidian Navy
  static const Color surfaceDark = Color(0xFF151D2E); // Elevated Dark Slate
  static const Color cardDarkSubtle = Color(0xFF1E293B);
  static const Color textDarkPrimary = Color(0xFFF8FAFC); // Crisp Off-White
  static const Color textDarkSecondary = Color(0xFF94A3B8); // Muted Blue-Grey
  static const Color borderDark = Color(0xFF222F44); // Dark border

  // Status & Indicator Colors
  static const Color positiveGreen = Color(0xFF10B981); // Emerald Green
  static const Color positiveGreenBg = Color(0xFFD1FAE5);
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Orange
  static const Color warningOrangeBg = Color(0xFFFEF3C7);
  static const Color criticalRed = Color(0xFFEF4444); // Crimson
  static const Color criticalRedBg = Color(0xFFFEE2E2);
  static const Color neutralGrey = Color(0xFF64748B);

  // Dark mode status backgrounds
  static const Color positiveGreenBgDark = Color(0xFF064E3B);
  static const Color warningOrangeBgDark = Color(0xFF78350F);
  static const Color criticalRedBgDark = Color(0xFF7F1D1D);

  // Corner Radii (Specified between 18–22px)
  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 14.0;

  // Dynamic Theme Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getBackground(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color getSurface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceWhite;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? textDarkPrimary : textLightPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? textDarkSecondary : textLightSecondary;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? borderDark : borderGrey;

  static Color getPillBackground(BuildContext context) =>
      isDark(context) ? cardDarkSubtle : backgroundLight;

  // Shadows
  static List<BoxShadow> getSoftShadow(BuildContext context) {
    if (isDark(context)) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNavy, secondaryElectric],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF1D4ED8)],
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

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF1F2937), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme Configuration (Material Design 3)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
        onSurface: textLightPrimary,
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

  // Dark Theme Configuration (Material Design 3)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: secondaryElectricLight,
        onPrimary: Colors.white,
        secondary: accentCyan,
        onSecondary: Colors.black,
        error: criticalRed,
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: textDarkPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDarkPrimary),
        titleTextStyle: TextStyle(
          color: textDarkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderDark, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: secondaryElectric,
          foregroundColor: Colors.white,
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
          foregroundColor: accentCyanLight,
          side: const BorderSide(color: accentCyanLight, width: 1.5),
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
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        hintStyle: const TextStyle(
          color: textDarkSecondary,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        elevation: 12,
        selectedItemColor: accentCyanLight,
        unselectedItemColor: textDarkSecondary,
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
