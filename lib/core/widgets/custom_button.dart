import 'package:flutter/material.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

enum ButtonVariant { primary, secondary, outlined, text, danger }
enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? customChild;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.isFullWidth ? double.infinity : null,
            height: _getHeight(),
            decoration: _getDecoration(isDark, isDisabled),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onPressed,
                borderRadius: AppBorderRadius.radiusMD,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(),
                    vertical: _getVerticalPadding(),
                  ),
                  child: _buildContent(isDark, isDisabled),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isDisabled) {
    final textStyle = _getTextStyle().copyWith(
      color: _getTextColor(isDark, isDisabled),
    );

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTextColor(isDark, isDisabled),
            ),
          ),
        ),
      );
    }

    if (widget.customChild != null) {
      return Center(child: widget.customChild!);
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getTextColor(isDark, isDisabled),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(widget.text, style: textStyle),
        ],
      );
    }

    return Center(
      child: Text(widget.text, style: textStyle),
    );
  }

  BoxDecoration _getDecoration(bool isDark, bool isDisabled) {
    Color backgroundColor;
    Color? borderColor;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case ButtonVariant.primary:
        backgroundColor = isDisabled
            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
            : (_isHovered ? AppColors.primaryDark : AppColors.primary);
        shadows = !isDisabled && _isHovered ? AppShadows.shadowPrimary : null;
        break;

      case ButtonVariant.secondary:
        backgroundColor = isDisabled
            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
            : (_isHovered ? AppColors.accentLight : AppColors.accent);
        shadows = !isDisabled && _isHovered ? AppShadows.shadowAccent : null;
        break;

      case ButtonVariant.outlined:
        backgroundColor = _isHovered
            ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.05))
            : Colors.transparent;
        borderColor = isDisabled
            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
            : AppColors.primary;
        break;

      case ButtonVariant.text:
        backgroundColor = _isHovered
            ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.05))
            : Colors.transparent;
        break;

      case ButtonVariant.danger:
        backgroundColor = isDisabled
            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
            : (_isHovered ? AppColors.errorLight : AppColors.error);
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: AppBorderRadius.radiusMD,
      border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
      boxShadow: shadows,
    );
  }

  Color _getTextColor(bool isDark, bool isDisabled) {
    if (isDisabled) {
      return isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return Colors.white;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return isDark ? AppColors.primaryLight : AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.buttonSmall;
      case ButtonSize.medium:
        return AppTypography.buttonMedium;
      case ButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSizes.buttonHeightSM;
      case ButtonSize.medium:
        return AppSizes.buttonHeightMD;
      case ButtonSize.large:
        return AppSizes.buttonHeightLG;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.lg;
      case ButtonSize.medium:
        return AppSpacing.xl2;
      case ButtonSize.large:
        return AppSpacing.xl3;
    }
  }

  double _getVerticalPadding() {
    return AppSpacing.sm;
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSizes.iconSM;
      case ButtonSize.medium:
        return AppSizes.iconMD;
      case ButtonSize.large:
        return AppSizes.iconLG;
    }
  }
}
