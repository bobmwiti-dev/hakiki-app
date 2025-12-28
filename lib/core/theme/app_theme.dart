import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Color constants
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryVariantLight = Color(0xFF64B5F6);
  static const Color primaryVariantDark = Color(0xFF0D47A1);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  
  static const Color secondaryLight = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryVariantLight = Color(0xFF4DB6AC);
  static const Color secondaryVariantDark = Color(0xFF00695C);
  static const Color onSecondaryLight = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  
  static const Color errorLight = Color(0xFFB00020);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);
  
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF2C2C2C);
  
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2C2C2C);
  
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);
  
  static const Color textHighEmphasisLight = Color(0xFF000000);
  static const Color textHighEmphasisDark = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisLight = Color(0x99000000);
  static const Color textMediumEmphasisDark = Color(0x99FFFFFF);
  static const Color textSecondary = Color(0xFF757575);
  
  static const Color neutralBorder = Color(0xFFE0E0E0);
  static const Color successAccent = Color(0xFF4CAF50);

  // Additional color getters for admin dashboard
  static Color get primaryBlue => primaryLight;
  static Color get primaryGreen => successAccent;
  static Color get warningColor => const Color(0xFFFF9800);
  static Color get errorColor => errorLight;
  static Color get infoColor => const Color(0xFF2196F3);

  static const Color successColor = successAccent;

  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get darkTheme => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryLight,
        onPrimary: onPrimaryLight,
        primaryContainer: primaryVariantLight,
        onPrimaryContainer: onPrimaryLight,
        secondary: secondaryLight,
        onSecondary: onSecondaryLight,
        secondaryContainer: secondaryVariantLight,
        onSecondaryContainer: onSecondaryLight,
        tertiary: successAccent,
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFC8E6C9),
        onTertiaryContainer: Color(0xFF1B5E20),
        error: errorLight,
        onError: onErrorLight,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        onSurfaceVariant: textSecondary,
        outline: neutralBorder,
        outlineVariant: Color(0xFFF5F5F5),
        shadow: shadowLight,
        scrim: shadowLight,
        inverseSurface: surfaceDark,
        onInverseSurface: onSurfaceDark,
        inversePrimary: primaryDark,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      dividerColor: dividerLight,
      textTheme: _buildTextTheme(isLight: true),
      dialogTheme: const DialogThemeData(backgroundColor: dialogLight),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryDark,
        onPrimary: onPrimaryDark,
        primaryContainer: primaryVariantDark,
        onPrimaryContainer: Color(0xFFFFFFFF),
        secondary: secondaryDark,
        onSecondary: onSecondaryDark,
        secondaryContainer: secondaryVariantDark,
        onSecondaryContainer: Color(0xFFFFFFFF),
        tertiary: successAccent,
        onTertiary: Color(0xFF000000),
        tertiaryContainer: Color(0xFF2E7D32),
        onTertiaryContainer: Color(0xFFFFFFFF),
        error: errorDark,
        onError: onErrorDark,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        onSurfaceVariant: textMediumEmphasisDark,
        outline: dividerDark,
        outlineVariant: Color(0xFF2C2C2C),
        shadow: shadowDark,
        scrim: shadowDark,
        inverseSurface: surfaceLight,
        onInverseSurface: onSurfaceLight,
        inversePrimary: primaryLight,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: dividerDark,
      textTheme: _buildTextTheme(isLight: false),
      dialogTheme: const DialogThemeData(backgroundColor: dialogDark),
    );
  }

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis =
        isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final Color textMediumEmphasis =
        isLight ? textMediumEmphasisLight : textMediumEmphasisDark;

    return TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400, color: textHighEmphasis),
      displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400, color: textHighEmphasis),
      displaySmall: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400, color: textHighEmphasis),
      headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: textHighEmphasis),
      headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: textHighEmphasis),
      headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textHighEmphasis),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500, color: textHighEmphasis),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textHighEmphasis, letterSpacing: 0.15),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textHighEmphasis, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textHighEmphasis, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textHighEmphasis, letterSpacing: 0.25),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textMediumEmphasis, letterSpacing: 0.4),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textHighEmphasis, letterSpacing: 0.1),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textMediumEmphasis, letterSpacing: 0.5),
    );
  }
}
