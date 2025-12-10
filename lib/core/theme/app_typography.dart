import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static String get fontFamily => GoogleFonts.inter().fontFamily!;
  
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  
  static TextStyle display1 = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: extraBold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle display2 = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: bold,
    height: 1.3,
    letterSpacing: -0.5,
  );
  
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: bold,
    height: 1.3,
    letterSpacing: -0.5,
  );
  
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.4,
  );
  
  static TextStyle h4 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
  );
  
  static TextStyle h5 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.5,
  );
  
  static TextStyle h6 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
  );
  
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: regular,
    height: 1.6,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: regular,
    height: 1.6,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
  );
  
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
  );
  
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
  );
}
