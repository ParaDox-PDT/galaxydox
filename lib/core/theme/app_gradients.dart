import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const spaceBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundDeep,
      AppColors.background,
      AppColors.backgroundMid,
      AppColors.background,
    ],
    stops: [0, 0.28, 0.7, 1],
  );

  static const screenVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x14000000),
      Color(0x22000000),
      Color(0x66020712),
      AppColors.backgroundDeep,
    ],
    stops: [0, 0.22, 0.68, 1],
  );

  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x33050B14),
      Color(0x9C040913),
      Color(0xE6030812),
    ],
    stops: [0, 0.24, 0.72, 1],
  );

  static const imageCardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x08000000), Color(0x22050A14), Color(0xB8061120)],
    stops: [0, 0.42, 1],
  );

  static const panelSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x2AFFFFFF), Color(0x08FFFFFF), Color(0x00FFFFFF)],
    stops: [0, 0.32, 1],
  );

  static RadialGradient ambientGlow({
    required Alignment alignment,
    required Color color,
    double radius = 0.7,
    double alpha = 0.32,
  }) {
    return RadialGradient(
      center: alignment,
      radius: radius,
      colors: [
        color.withValues(alpha: alpha),
        color.withValues(alpha: 0),
      ],
    );
  }

  static LinearGradient storySurface({required Color accent}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.06),
        accent.withValues(alpha: 0.12),
        AppColors.surfaceElevated.withValues(alpha: 0.92),
        AppColors.surface.withValues(alpha: 0.98),
      ],
      stops: const [0, 0.18, 0.56, 1],
    );
  }
}
