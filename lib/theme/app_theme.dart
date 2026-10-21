import 'package:flutter/material.dart';

class AppTheme {
  static const red = Color(0xFFD32F2F);
  static const darkRed = Color(0xFFB71C1C);
  static const navy = Color(0xFF17233B);
  static const ink = Color(0xFF202126);
  static const paleRed = Color(0xFFFCECEF);
  static const bg = Color(0xFFF5F6F8);
  static const surface = Colors.white;
  static const border = Color(0xFFE1E5EA);
  static const muted = Color(0xFF7A8495);
  static const success = Color(0xFF2E7D32);
  static const info = Color(0xFF1976D2);
  static const warning = Color(0xFFED6C02);
  static const purple = Color(0xFF7C3AED);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.light),
        fontFamily: 'Arial',
        visualDensity: VisualDensity.standard,
        appBarTheme: const AppBarTheme(backgroundColor: surface, foregroundColor: ink, elevation: 0, surfaceTintColor: Colors.transparent, centerTitle: false),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: border)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border)),
        ),
      );
}
