import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFF0284C7),        // Sky 600
    secondary: Color(0xFF4F46E5),      // Indigo 600
    tertiary: Color(0xFFE2E8F0),       // Slate 200
    inversePrimary: Color(0xFF0F172A), // Slate 900
    surfaceContainerHighest: Color(0xFFF1F5F9),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 3,
    shadowColor: Colors.black.withValues(alpha: 0.06),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);