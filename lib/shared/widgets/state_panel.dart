import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'frosted_panel.dart';

class StatePanelAction {
  const StatePanelAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.emphasis = StatePanelActionEmphasis.primary,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final StatePanelActionEmphasis emphasis;
}

enum StatePanelActionEmphasis { primary, secondary }

class StatePanel extends StatelessWidget {
  const StatePanel({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.accent,
    this.actions = const [],
  });

  final String title;
  final String message;
  final IconData? icon;
  final Color? accent;
  final List<StatePanelAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? AppColors.primary;

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      borderColor: color.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: color.withValues(alpha: 0.26)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 18),
          ],
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(message, style: theme.textTheme.bodyLarge),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final action in actions)
                  switch (action.emphasis) {
                    StatePanelActionEmphasis.primary => FilledButton.icon(
                      onPressed: action.onPressed,
                      icon: Icon(action.icon),
                      label: Text(action.label),
                    ),
                    StatePanelActionEmphasis.secondary => OutlinedButton.icon(
                      onPressed: action.onPressed,
                      icon: Icon(action.icon),
                      label: Text(action.label),
                    ),
                  },
              ],
            ),
          ],
        ],
      ),
    );
  }
}
