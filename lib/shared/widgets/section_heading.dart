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
            Text(
              eyebrow.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
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
            const SizedBox(width: 16),
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
