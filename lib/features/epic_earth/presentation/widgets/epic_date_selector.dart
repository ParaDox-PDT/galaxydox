import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../cubit/epic_earth_state.dart';

class EpicDateSelector extends StatelessWidget {
  const EpicDateSelector({
    super.key,
    required this.state,
    required this.onPickDate,
    required this.onLoadLatest,
    required this.onDateSelected,
  });

  final EpicEarthState state;
  final VoidCallback onPickDate;
  final VoidCallback onLoadLatest;
  final ValueChanged<DateTime> onDateSelected;

  static final DateFormat _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = state.selectedDate;
    final visibleDates = state.availableDates.take(12).toList(growable: false);

    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;

              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    selectedDate == null
                        ? '${state.availableDates.length} available dates'
                        : '${_dateFormat.format(selectedDate)} | ${state.availableDates.length} available dates',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onPickDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Choose date'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onLoadLatest,
                    icon: const Icon(Icons.public_rounded),
                    label: const Text('Latest'),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 16), actions],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 18),
                  actions,
                ],
              );
            },
          ),
          if (visibleDates.isNotEmpty) ...[
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (var index = 0; index < visibleDates.length; index++) ...[
                    ChoiceChip(
                      selected: _sameDay(visibleDates[index], selectedDate),
                      label: Text(_dateFormat.format(visibleDates[index])),
                      selectedColor: AppColors.tertiary.withValues(alpha: 0.22),
                      side: BorderSide(
                        color: _sameDay(visibleDates[index], selectedDate)
                            ? AppColors.tertiary.withValues(alpha: 0.55)
                            : AppColors.outlineSoft,
                      ),
                      onSelected: (_) => onDateSelected(visibleDates[index]),
                    ),
                    if (index != visibleDates.length - 1)
                      const SizedBox(width: AppConstants.sectionGapSmall),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static bool _sameDay(DateTime date, DateTime? other) {
    return other != null &&
        date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
