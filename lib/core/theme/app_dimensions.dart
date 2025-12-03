// Design System - Spacing & Sizing
import 'package:flutter/material.dart';

class AppSpacing {
  // ==================== SPACING SCALE ====================
  // Following 4px base unit (4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
  static const double xl6 = 64.0;
  static const double xl7 = 80.0;
  static const double xl8 = 96.0;
  
  // ==================== PADDING PRESETS ====================
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXL2 = EdgeInsets.all(xl2);
  static const EdgeInsets paddingXL3 = EdgeInsets.all(xl3);
  
  // Horizontal padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingHorizontalXL2 = EdgeInsets.symmetric(horizontal: xl2);
  
  // Vertical padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets paddingVerticalXL2 = EdgeInsets.symmetric(vertical: xl2);
}

class AppBorderRadius {
  // ==================== BORDER RADIUS ====================
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double full = 9999.0;
  
  // BorderRadius presets
  static BorderRadius radiusSM = BorderRadius.circular(sm);
  static BorderRadius radiusMD = BorderRadius.circular(md);
  static BorderRadius radiusLG = BorderRadius.circular(lg);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusXL2 = BorderRadius.circular(xl2);
  static BorderRadius radiusFull = BorderRadius.circular(full);
  
  // Top-only radius
  static BorderRadius radiusTopSM = const BorderRadius.only(
    topLeft: Radius.circular(sm),
    topRight: Radius.circular(sm),
  );
  static BorderRadius radiusTopMD = const BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );
  static BorderRadius radiusTopLG = const BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
}

class AppShadows {
  // ==================== ELEVATION SHADOWS ====================
  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  static List<BoxShadow> shadowXL2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];
  
  // Colored shadows for primary actions
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowAccent = [
    BoxShadow(
      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppSizes {
  // ==================== ICON SIZES ====================
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;
  static const double iconXL2 = 48.0;
  
  // ==================== BUTTON HEIGHTS ====================
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;
  
  // ==================== INPUT HEIGHTS ====================
  static const double inputHeightSM = 36.0;
  static const double inputHeightMD = 44.0;
  static const double inputHeightLG = 52.0;
  
  // ==================== CARD SIZES ====================
  static const double cardMinHeight = 120.0;
  static const double cardMaxWidth = 400.0;
  
  // ==================== AVATAR SIZES ====================
  static const double avatarSM = 32.0;
  static const double avatarMD = 40.0;
  static const double avatarLG = 56.0;
  static const double avatarXL = 80.0;
  
  // ==================== BREAKPOINTS (Responsive) ====================
  static const double mobile = 640.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double desktopLarge = 1280.0;
}
