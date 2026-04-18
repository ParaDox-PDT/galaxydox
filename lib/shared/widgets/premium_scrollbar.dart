import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PremiumScrollbar extends StatelessWidget {
  const PremiumScrollbar({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(false),
        trackVisibility: const WidgetStatePropertyAll(false),
        interactive: true,
        radius: const Radius.circular(999),
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return 5;
          }

          if (states.contains(WidgetState.hovered)) {
            return 4.5;
          }

          return 4;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return AppColors.textSecondary.withValues(alpha: 0.5);
          }

          if (states.contains(WidgetState.hovered)) {
            return AppColors.textSecondary.withValues(alpha: 0.36);
          }

          return AppColors.textMuted.withValues(alpha: 0.22);
        }),
      ),
      child: Scrollbar(
        controller: controller,
        interactive: true,
        radius: const Radius.circular(999),
        child: child,
      ),
    );
  }
}
