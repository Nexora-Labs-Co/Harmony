import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Harmony
  static const Color nxBlack = Color(0xFF090C02); // Dark / Background / Textos oscuros
  static const Color nxWhite = Color(0xFFEBF5EE); // Light / Textos claros / Detalles

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: nxBlack,
        brightness: Brightness.light,
        surface: nxWhite,
        onSurface: nxBlack,
      ),
      scaffoldBackgroundColor: nxWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: nxWhite,
        foregroundColor: nxBlack,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: nxWhite,
        brightness: Brightness.dark,
        surface: nxBlack,
        onSurface: nxWhite,
      ),
      scaffoldBackgroundColor: nxBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: nxBlack,
        foregroundColor: nxWhite,
      ),
    );
  }
}
