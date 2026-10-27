import 'package:flutter/material.dart';

class AppTheme {
  static const Color nxBlack = Color(0xFF090C02);
  static const Color nxWhite = Color(0xFFEBF5EE);
  static const Color nxGrey900 = Color(0xFF1A1A1A);
  static const Color nxGrey700 = Color(0xFF3A3A3A);
  static const Color nxGrey500 = Color(0xFF6B6B6B);
  static const Color nxGrey300 = Color(0xFFB0B0B0);
  static const Color nxGrey100 = Color(0xFFE5E5E5);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: nxBlack,
        onPrimary: nxWhite,
        secondary: nxGrey700,
        onSecondary: nxWhite,
        surface: nxWhite,
        onSurface: nxBlack,
        background: nxWhite,
        onBackground: nxBlack,
        error: Color(0xFFB00020),
        onError: nxWhite,
        outline: nxGrey300,
        surfaceContainerHighest: nxGrey100,
      ),
      scaffoldBackgroundColor: nxWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: nxWhite,
        foregroundColor: nxBlack,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: nxWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: nxGrey300),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: nxBlack,
        inactiveTrackColor: nxGrey300,
        thumbColor: nxBlack,
        overlayColor: Color(0x1A090C02),
      ),
      iconTheme: const IconThemeData(color: nxBlack),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: nxWhite,
        onPrimary: nxBlack,
        secondary: nxGrey300,
        onSecondary: nxBlack,
        surface: nxBlack,
        onSurface: nxWhite,
        background: nxBlack,
        onBackground: nxWhite,
        error: Color(0xFFCF6679),
        onError: nxBlack,
        outline: nxGrey700,
        surfaceContainerHighest: nxGrey900,
      ),
      scaffoldBackgroundColor: nxBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: nxBlack,
        foregroundColor: nxWhite,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: nxBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: nxGrey700),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: nxWhite,
        inactiveTrackColor: nxGrey700,
        thumbColor: nxWhite,
        overlayColor: Color(0x1AEBF5EE),
      ),
      iconTheme: const IconThemeData(color: nxWhite),
    );
  }
}