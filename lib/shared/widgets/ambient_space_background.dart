import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class AmbientSpaceBackground extends StatelessWidget {
  const AmbientSpaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.spaceBackdrop),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.ambientGlow(
                alignment: const Alignment(-0.9, -0.8),
                color: AppColors.primary,
                radius: 0.85,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.ambientGlow(
                alignment: const Alignment(0.95, -0.25),
                color: AppColors.secondary,
                radius: 0.62,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.ambientGlow(
                alignment: const Alignment(0.15, 1.1),
                color: AppColors.tertiary,
                radius: 0.8,
              ),
            ),
          ),
        ),
        IgnorePointer(child: CustomPaint(painter: _StarFieldPainter())),
      ],
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.7);
    final random = math.Random(42);

    for (var index = 0; index < 110; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.4 + 0.2;
      final opacity = random.nextDouble() * 0.7 + 0.15;

      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        paint..color = AppColors.textPrimary.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
