// lib/core/widgets/scroll_frost_appbar.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';

class ScrollFrostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const ScrollFrostAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final surfaceColor = isDark 
        ? AppColors.darkBackground.withOpacity(0.7) 
        : Colors.white.withOpacity(0.7);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          title: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.darkBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: surfaceColor,
          elevation: 0,
          foregroundColor: isDark ? Colors.white : AppColors.darkBackground,
          actions: actions,
        ),
      ),
    );
  }
}