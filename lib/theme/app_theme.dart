import 'package:flutter/material.dart';

// Poznámka: appka (obrazovky pod lib/screens/) si zatiaľ farby berie priamo
// z core/constants/app_colors.dart, nie z Theme.of(context) — tieto ThemeData
// preto zatiaľ ovplyvnia najmä natívne Material widgety (napr. SnackBar,
// TextField focus border), nie kompletný vzhľad každej obrazovky.
class AppTheme {
  static ThemeData dark(Color accent) => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: accent,
          unselectedItemColor: Colors.grey[600],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: accent),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      );

  static ThemeData light(Color accent) => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: accent,
          secondary: accent,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: accent,
          unselectedItemColor: Colors.grey[500],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: accent),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
        cardColor: Colors.white,
        useMaterial3: true,
      );
}
