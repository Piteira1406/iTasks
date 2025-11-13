// lib/core/widgets/glass_card.dart
import 'package:flutter/material.dart';
import 'dart:ui'; // Para o ImageFilter

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.blur = 10.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // 3. Usa o borderRadius que recebeu, ou o padrão (16.0) se for nulo
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16.0);

    return ClipRRect(
      borderRadius: effectiveBorderRadius, // <-- 4. Usado aqui
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            // Usa a cor 'surface' do seu novo tema
            // (que já definimos como lightGlass/darkGlass)
            color: Theme.of(context).colorScheme.surface,
            borderRadius: effectiveBorderRadius, // <-- 5. E usado aqui
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
