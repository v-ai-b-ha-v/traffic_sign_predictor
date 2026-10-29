import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1E293B),        // Slate 800
    primary: Color(0xFF38BDF8),        // Sky 400
    secondary: Color(0xFF6366F1),      // Indigo 500
    tertiary: Color(0xFF334155),       // Slate 700
    inversePrimary: Colors.white,
    surfaceContainerHighest: Color(0xFF283548),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E293B),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);