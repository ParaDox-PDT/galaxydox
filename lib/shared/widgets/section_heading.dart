import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        final headingContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 1,
                  color: AppColors.primaryStrong.withValues(alpha: 0.72),
                ),
                const SizedBox(width: 10),
                Text(
                  eyebrow.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(subtitle, style: theme.textTheme.bodyLarge),
          ],
        );

        if (compact || actionLabel == null || onActionPressed == null) {
          return headingContent;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: headingContent),
            const SizedBox(width: 18),
            OutlinedButton(
              onPressed: onActionPressed,
              child: Text(actionLabel!),
            ),
          ],
        );
      },
    );
  }
}
