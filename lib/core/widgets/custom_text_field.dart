import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool enabled;
  final String? helperText;
  final bool showCharacterCount;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.icon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.helperText,
    this.showCharacterCount = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  bool _isHovered = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
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

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (!_isFocused) _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
            if (hasFocus) {
              _controller.forward();
            } else if (!_isHovered) {
              _controller.reverse();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                Text(
                  widget.label!,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: AppBorderRadius.radiusMD,
                  boxShadow: _isFocused || _isHovered
                      ? AppShadows.shadowSM
                      : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: _obscureText,
                  validator: widget.validator,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  maxLength: widget.showCharacterCount ? widget.maxLength : null,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: widget.icon != null
                        ? Icon(
                            widget.icon,
                            color: _isFocused
                                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                : (isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary),
                            size: AppSizes.iconMD,
                          )
                        : null,
                    suffixIcon: _buildSuffixIcon(isDark),
                    hintText: widget.hintText,
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    helperText: widget.helperText,
                    helperStyle: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? (_isFocused
                                ? AppColors.darkSurfaceVariant
                                : AppColors.darkSurface)
                        : (_isFocused
                                ? AppColors.lightSurface
                                : AppColors.lightSurfaceVariant),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: widget.maxLines > 1 ? AppSpacing.lg : AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusMD,
                      borderSide: BorderSide(
                        color: _isHovered
                            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                            : (isDark
                                    ? AppColors.darkBorder.withValues(alpha: 0.3)
                                    : AppColors.lightBorder),
                        width: _isHovered ? 2 : 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.errorLight : AppColors.error,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.errorLight : AppColors.error,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusMD,
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.2)
                            : AppColors.lightBorder.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: _isFocused
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          size: AppSizes.iconMD,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _isFocused
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          size: AppSizes.iconMD,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }
}
