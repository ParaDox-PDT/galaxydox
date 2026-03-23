import 'package:flutter/material.dart';

class MetadataRow extends StatelessWidget {
  const MetadataRow({
    super.key,
    required this.label,
    required this.value,
    this.valueAlign = TextAlign.right,
  });

  final String label;
  final String value;
  final TextAlign valueAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: valueAlign,
            style: theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
