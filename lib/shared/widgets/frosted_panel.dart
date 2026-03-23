import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppConstants.radiusLarge,
    this.backgroundColor,
    this.borderColor,
    this.blurSigma = 18,
    this.showSheen = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurSigma;
  final bool showSheen;

  @override
  Widget build(BuildContext context) {
    final baseColor = backgroundColor ?? AppColors.surfaceElevated;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: 0.78),
                AppColors.surfaceStrong.withValues(alpha: 0.68),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? AppColors.outlineSoft),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.26),
                blurRadius: 34,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (showSheen)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.panelSheen,
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
