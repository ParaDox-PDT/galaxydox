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
    final canPop = Navigator.of(context).canPop();
    final backButton = canPop
        ? OutlinedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
          )
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final narrow = constraints.maxWidth < 480;

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: narrow
                  ? theme.textTheme.headlineLarge
                  : compact
                  ? theme.textTheme.headlineLarge
                  : theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: compact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: compact
                  ? theme.textTheme.bodyMedium
                  : theme.textTheme.bodyLarge,
            ),
          ],
        );

        final trailing = Wrap(spacing: 12, runSpacing: 12, children: actions);

        if (compact) {
          final hasTopBar = backButton != null || actions.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTopBar) ...[
                Row(
                  children: [
                    if (backButton != null) ...[backButton],
                    if (backButton != null && actions.isNotEmpty)
                      const SizedBox(width: 12),
                    if (actions.isNotEmpty) ...[
                      const Spacer(),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: trailing,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
              info,
            ],
          );
        }

        return Row(
          children: [
            if (backButton != null) ...[backButton, const SizedBox(width: 16)],
            Expanded(child: info),
            if (actions.isNotEmpty) ...[const SizedBox(width: 16), trailing],
          ],
        );
      },
    );
  }
}
