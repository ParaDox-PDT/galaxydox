import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.accent, this.leading});

  final String label;
  final Color? accent;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.surfaceStrong;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent == null
            ? AppColors.surfaceStrong.withValues(alpha: 0.5)
            : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: accent == null
              ? AppColors.outlineSoft
              : color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
  }
}
