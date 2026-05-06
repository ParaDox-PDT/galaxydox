import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class AmbientSpaceBackground extends StatelessWidget {
  const AmbientSpaceBackground({super.key});

  static final _glow1 = BoxDecoration(
    gradient: AppGradients.ambientGlow(
      alignment: const Alignment(-0.95, -0.82),
      color: AppColors.primaryStrong,
      radius: 0.95,
      alpha: 0.26,
    ),
  );

  static final _glow2 = BoxDecoration(
    gradient: AppGradients.ambientGlow(
      alignment: const Alignment(1.05, -0.2),
      color: AppColors.secondary,
      radius: 0.72,
      alpha: 0.18,
    ),
  );

  static final _glow3 = BoxDecoration(
    gradient: AppGradients.ambientGlow(
      alignment: const Alignment(0.15, 1.08),
      color: AppColors.tertiary,
      radius: 0.84,
      alpha: 0.18,
    ),
  );

  static final _orbital = _OrbitalPainter();
  static final _stars = _StarFieldPainter();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.spaceBackdrop),
        ),
        Positioned.fill(child: DecoratedBox(decoration: _glow1)),
        Positioned.fill(child: DecoratedBox(decoration: _glow2)),
        Positioned.fill(child: DecoratedBox(decoration: _glow3)),
        IgnorePointer(child: CustomPaint(painter: _orbital)),
        IgnorePointer(child: CustomPaint(painter: _stars)),
      ],
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.7);
    final random = math.Random(42);

    for (var index = 0; index < 120; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.45 + 0.18;
      final opacity = random.nextDouble() * 0.7 + 0.12;

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

class _OrbitalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final softPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.outlineSoft.withValues(alpha: 0.28);

    final strongerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.outline.withValues(alpha: 0.24);

    final largeRect = Rect.fromCircle(
      center: Offset(size.width * 0.14, size.height * 0.42),
      radius: size.width * 0.62,
    );
    final mediumRect = Rect.fromCircle(
      center: Offset(size.width * 0.82, size.height * 0.12),
      radius: size.width * 0.46,
    );
    final lowerRect = Rect.fromCircle(
      center: Offset(size.width * 0.68, size.height * 0.92),
      radius: size.width * 0.34,
    );

    canvas.drawArc(largeRect, 3.4, 1.7, false, softPaint);
    canvas.drawArc(largeRect, 5.15, 0.72, false, strongerPaint);
    canvas.drawArc(mediumRect, 2.15, 1.36, false, softPaint);
    canvas.drawArc(lowerRect, 4.5, 1.08, false, strongerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
