// lib/core/widgets/responsive_text.dart

import 'package:flutter/material.dart';
import 'responsive_scaffold.dart';

/// Text widget that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    required this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = mobileFontSize;

    if (DeviceType.isDesktop(context) && desktopFontSize != null) {
      fontSize = desktopFontSize!;
    } else if (DeviceType.isTablet(context) && tabletFontSize != null) {
      fontSize = tabletFontSize!;
    }

    return Text(
      text,
      style: style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Sized box that adapts to screen size
class ResponsiveSizedBox extends StatelessWidget {
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    double? height = mobileHeight;
    double? width = mobileWidth;

    if (DeviceType.isDesktop(context)) {
      height = desktopHeight ?? height;
      width = desktopWidth ?? width;
    } else if (DeviceType.isTablet(context)) {
      height = tabletHeight ?? height;
      width = tabletWidth ?? width;
    }

    return SizedBox(
      height: height,
      width: width,
      child: child,
    );
  }
}
