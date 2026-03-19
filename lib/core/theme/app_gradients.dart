import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const spaceBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.backgroundDeep, Color(0xFF091423), AppColors.background],
  );

  static const screenVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x22000000), Color(0x33000000), AppColors.backgroundDeep],
  );

  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x05000000), Color(0x7F030812), Color(0xE6030812)],
  );

  static const cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x18000000), Color(0xCC06101E)],
  );

  static RadialGradient ambientGlow({
    required Alignment alignment,
    required Color color,
    double radius = 0.7,
  }) {
    return RadialGradient(
      center: alignment,
      radius: radius,
      colors: [color.withValues(alpha: 0.32), color.withValues(alpha: 0)],
    );
  }
}
