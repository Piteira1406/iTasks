// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Cores Primárias (usadas para botões, AppBar)
  static const Color primaryBlue = Color(0xFF007AFF); // Cor principal Apple Blue
  static const Color secondaryColor = Color(0xFFFF9500); // Cor de destaque (Laranja/Amarelo)
  
  // Cores de Status Kanban
  static const Color todoColor = Color(0xFF5AC8FA); // Azul Claro
  static const Color doingColor = Color(0xFFFFCC00); // Amarelo
  static const Color doneColor = Color(0xFF34C759); // Verde

  // Cores para o Efeito Glass (usadas como base para o fundo)
  static const Color lightBackground = Color(0xFFF2F2F7); 
  static const Color darkBackground = Color(0xFF1C1C1E); 
  
  // Cores de Transparência para o Vidro
  static Color glassLight = Colors.white.withOpacity(0.3);
  static Color glassDark = Colors.white.withOpacity(0.05);

  // Cores do Contorno do Vidro
  static Color glassBorderLight = Colors.white.withOpacity(0.5);
  static Color glassBorderDark = Colors.white.withOpacity(0.1);
}