import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? blur;
  final BorderRadius? borderRadius;
  final bool isHoverable;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10.0,
    this.borderRadius,
    this.isHoverable = false,
    this.onTap,
    this.backgroundColor,
    this.elevation = 0,
    this.border,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 0,
      end: (widget.elevation ?? 0) + 4,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = widget.borderRadius ?? AppBorderRadius.radiusLG;
    final effectivePadding = widget.padding ?? AppSpacing.paddingLG;

    return MouseRegion(
      onEnter: widget.isHoverable ? (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      } : null,
      onExit: widget.isHoverable ? (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      } : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: effectiveBorderRadius,
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: (isDark ? AppColors.primaryLight : AppColors.primary)
                                .withValues(alpha: 0.1),
                            blurRadius: _elevationAnimation.value * 4,
                            offset: Offset(0, _elevationAnimation.value),
                          ),
                        ]
                      : (widget.elevation != null && widget.elevation! > 0)
                          ? AppShadows.shadowMD
                          : null,
                ),
                child: ClipRRect(
                  borderRadius: effectiveBorderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur ?? 10.0,
                      sigmaY: widget.blur ?? 10.0,
                    ),
                    child: Container(
                      padding: effectivePadding,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ??
                            (isDark
                                ? AppColors.darkSurface.withValues(alpha: 0.7)
                                : AppColors.lightSurface.withValues(alpha: 0.7)),
                        borderRadius: effectiveBorderRadius,
                        border: widget.border ??
                            Border.all(
                              color: (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.3)),
                              width: 1,
                            ),
                        gradient: _isHovered
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  (isDark ? AppColors.primaryLight : AppColors.primary)
                                      .withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              )
                            : null,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
