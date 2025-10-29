// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definimos as cores num local central para ser mais fácil de gerir.
// O seu colega pode ter criado um ficheiro app_colors.dart,
// se sim, basta importar esse ficheiro.
class _AppColors {
  static const Color primaryBlue = Color(0xFF0A7AFF);
  static const Color lightBackground = Color(0xFFF4F4F8); // Fundo claro
  static const Color darkBackground = Color(0xFF121212); // Fundo escuro
  static const Color darkSurface = Color(
    0xFF1E1E1E,
  ); // Cor das "superfícies" escuras
}

class AppTheme {
  // O 'TextTheme' base que usa a fonte 'Inter'.
  // O main.dart vai consumir 'AppTheme.lightTheme', etc.
  static final _baseTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      bodyMedium: TextStyle(fontSize: 14),
    ),
  );

  // --- TEMA CLARO (Light) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // Cor de fundo principal da app
    scaffoldBackgroundColor: _AppColors.lightBackground,
    // Esquema de cores principal
    colorScheme: const ColorScheme.light(
      primary: _AppColors.primaryBlue,
      secondary: _AppColors.lightBackground,
      background: _AppColors.lightBackground,
      surface: Colors.white, // Cor dos 'Cards'
      onPrimary: Colors.white, // Texto num botão primário
      onBackground: Colors.black, // Texto no fundo
      onSurface: Colors.black, // Texto nos 'Cards'
      error: Colors.redAccent,
    ),
    // Aplicar o tema de texto
    textTheme: _baseTextTheme.apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    // Tema para a AppBar (para o seu 'scroll_frost_appbar')
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Fundamental para o 'glass'
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // --- TEMA ESCURO (Dark) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: _AppColors.primaryBlue,
      secondary: _AppColors.darkSurface,
      background: _AppColors.darkBackground,
      surface: _AppColors.darkSurface, // Cor dos 'Cards'
      onPrimary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: Colors.redAccent,
    ),
    // Aplicar o tema de texto
    textTheme: _baseTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    // Tema para a AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Fundamental para o 'glass'
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
