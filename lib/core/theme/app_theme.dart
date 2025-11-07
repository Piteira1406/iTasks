// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Definição das novas cores pedidas
class _AppColors {
  // Cores Base
  static const Color primaryBlue = Color(
    0xFF0A7AFF,
  ); // Azul de Ação (links, botões)
  static const Color softBlueBackground = Color.fromARGB(
    255,
    138,
    166,
    190,
  ); // "azul soft"
  static const Color midnightBlueBackground = Color(
    0xFF0D1B2A,
  ); // "azul meia-noite"

  // Cores de Texto (para contraste)
  static const Color darkText = Color(0xFF0D1B2A); // Texto para o tema claro
  static const Color lightText = Color(0xFFE0EFFF); // Texto para o tema escuro

  // Cores de Superfície (Cards/Glass)
  static const Color lightGlass = Color(0x33FFFFFF); // Branco com 20% opacidade
  static const Color darkGlass = Color(0x1AFFFFFF); // Branco com 10% opacidade
  static const Color darkSurface = Color(
    0xFF1B263B,
  ); // Um azul um pouco mais claro para cards escuros
}

class AppTheme {
  // O 'TextTheme' base que usa a fonte 'Inter'.
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
    // Cor de fundo principal ("azul soft")
    scaffoldBackgroundColor: _AppColors.softBlueBackground,
    // Esquema de cores principal
    colorScheme: const ColorScheme.light(
      primary: _AppColors.primaryBlue,
      secondary: _AppColors.softBlueBackground,
      background: _AppColors.softBlueBackground,
      surface: _AppColors.lightGlass, // Cor dos 'Cards' de vidro
      onPrimary: Colors.white, // Texto num botão primário
      onBackground:
          _AppColors.darkText, // Texto no fundo ("darkText" para contraste)
      onSurface: _AppColors.darkText, // Texto nos 'Cards'
      error: Colors.redAccent,
    ),
    // Aplicar o tema de texto
    textTheme: _baseTextTheme.apply(
      bodyColor: _AppColors.darkText,
      displayColor: _AppColors.darkText,
    ),
    // Tema para a AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _AppColors.darkText), // Ícones escuros
      titleTextStyle: _baseTextTheme.titleMedium?.copyWith(
        color: _AppColors.darkText,
      ),
    ),
  );

  // --- TEMA ESCURO (Dark) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // Cor de fundo principal ("azul meia-noite")
    scaffoldBackgroundColor: _AppColors.midnightBlueBackground,
    colorScheme: const ColorScheme.dark(
      primary: _AppColors.primaryBlue,
      secondary: _AppColors.darkSurface,
      background: _AppColors.midnightBlueBackground,
      surface: _AppColors.darkGlass, // Cor dos 'Cards' de vidro
      onPrimary: Colors.white,
      onBackground:
          _AppColors.lightText, // Texto no fundo ("lightText" para contraste)
      onSurface: _AppColors.lightText, // Texto nos 'Cards'
      error: Colors.redAccent,
    ),
    // Aplicar o tema de texto
    textTheme: _baseTextTheme.apply(
      bodyColor: _AppColors.lightText,
      displayColor: _AppColors.lightText,
    ),
    // Tema para a AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _AppColors.lightText), // Ícones claros
      titleTextStyle: _baseTextTheme.titleMedium?.copyWith(
        color: _AppColors.lightText,
      ),
    ),
  );
}
