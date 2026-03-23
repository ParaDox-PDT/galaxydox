import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyLarge),
          ],
        );

        final trailing = Wrap(spacing: 12, runSpacing: 12, children: actions);

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              info,
              if (actions.isNotEmpty) ...[const SizedBox(height: 16), trailing],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: info),
            if (actions.isNotEmpty) ...[const SizedBox(width: 16), trailing],
          ],
        );
      },
    );
  }
}
