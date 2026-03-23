import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/entities/near_earth_object.dart';
import '../providers/neo_controller.dart';
import '../widgets/neo_loading_view.dart';

class NeoPage extends ConsumerWidget {
  const NeoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(neoControllerProvider);
    final controller = ref.read(neoControllerProvider.notifier);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: PremiumRefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pagePadding,
                      12,
                      AppConstants.pagePadding,
                      42,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: 'Near-Earth Objects',
                          subtitle:
                              '${DateFormat.yMMMd().format(state.startDate)} - ${DateFormat.yMMMd().format(state.endDate)}',
                          actions: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _pickDateRange(context, controller, state),
                              icon: const Icon(Icons.date_range_rounded),
                              label: const Text('Change range'),
                            ),
                            FilledButton.icon(
                              onPressed: controller.refresh,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ).animate().fadeIn(duration: AppConstants.motionMedium),
                        const SizedBox(height: AppConstants.stackGap),
                        const _IntroPanel()
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 70),
                              duration: AppConstants.motionMedium,
                            )
                            .slideY(begin: 0.03, end: 0),
                        const SizedBox(height: AppConstants.stackGap),
                        if (state.status == NeoStatus.success &&
                            state.objects.isNotEmpty)
                          _OverviewRow(objects: state.objects)
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 120),
                                duration: AppConstants.motionMedium,
                              )
                              .slideY(begin: 0.03, end: 0),
                        if (state.status == NeoStatus.success &&
                            state.objects.isNotEmpty)
                          const SizedBox(height: AppConstants.stackGap),
                        if (state.isLoading) const NeoLoadingView(),
                        if (state.hasError)
                          StatePanel(
                            title: 'Unable to load asteroid feed',
                            message: state.error!.message,
                            icon: Icons.radar_rounded,
                            accent: AppColors.warning,
                            actions: [
                              StatePanelAction(
                                label: 'Try again',
                                icon: Icons.refresh_rounded,
                                onPressed: controller.refresh,
                              ),
                            ],
                          ),
                        if (state.isEmpty)
                          StatePanel(
                            title: 'No near-earth objects found',
                            message:
                                'NASA returned an empty feed for this date window. Try refreshing or choosing another range within the 7-day feed limit.',
                            icon: Icons.public_off_rounded,
                            accent: AppColors.secondary,
                            actions: [
                              StatePanelAction(
                                label: 'Retry',
                                icon: Icons.refresh_rounded,
                                onPressed: controller.refresh,
                              ),
                              StatePanelAction(
                                label: 'Choose range',
                                icon: Icons.date_range_rounded,
                                onPressed: () =>
                                    _pickDateRange(context, controller, state),
                                emphasis: StatePanelActionEmphasis.secondary,
                              ),
                            ],
                          ),
                        if (state.status == NeoStatus.success &&
                            state.objects.isNotEmpty)
                          _NeoContent(objects: state.objects),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    NeoController controller,
    NeoState state,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: state.startDate,
        end: state.endDate,
      ),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primaryStrong,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    final end = picked.duration.inDays > 6
        ? picked.start.add(const Duration(days: 6))
        : picked.end;

    HapticFeedback.selectionClick();
    await controller.setDateRange(startDate: picked.start, endDate: end);
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final theme = Theme.of(context);

          final lead = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A readable asteroid intelligence feed',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'This view translates raw NASA telemetry into strong visual hierarchy, letting users scan hazard level, scale, speed, and proximity without losing the scientific nuance.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              AppChip(label: 'Hazard-first hierarchy'),
              AppChip(label: 'Velocity and miss distance'),
              AppChip(label: 'Diameter range'),
              AppChip(label: '7-day feed window'),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [lead, const SizedBox(height: 18), chips],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: lead),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: chips),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.objects});

  final List<NearEarthObject> objects;

  @override
  Widget build(BuildContext context) {
    final hazardousCount = objects.where((object) => object.isHazardous).length;
    final fastest = objects.reduce(
      (left, right) =>
          left.relativeVelocityKilometersPerSecond >
              right.relativeVelocityKilometersPerSecond
          ? left
          : right,
    );
    final closest = objects.reduce(
      (left, right) =>
          left.missDistanceKilometers < right.missDistanceKilometers
          ? left
          : right,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 920;

        final cards = [
          _StatCard(
            label: 'Tracked objects',
            value: objects.length.toString(),
            accent: AppColors.primary,
            helper: 'Within the selected NASA feed window',
          ),
          _StatCard(
            label: 'Potentially hazardous',
            value: hazardousCount.toString(),
            accent: hazardousCount > 0 ? AppColors.warning : AppColors.tertiary,
            helper: hazardousCount > 0
                ? 'Requires closer attention'
                : 'No high-risk flags in this range',
          ),
          _StatCard(
            label: 'Fastest approach',
            value:
                '${fastest.relativeVelocityKilometersPerSecond.toStringAsFixed(1)} km/s',
            accent: AppColors.secondary,
            helper: fastest.name,
          ),
          _StatCard(
            label: 'Closest pass',
            value: _formatDistanceCompact(closest.missDistanceKilometers),
            accent: AppColors.tertiary,
            helper: closest.name,
          ),
        ];

        if (compact) {
          return Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index != cards.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              Expanded(child: cards[index]),
              if (index != cards.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}

class _NeoContent extends StatelessWidget {
  const _NeoContent({required this.objects});

  final List<NearEarthObject> objects;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Feed',
          title: 'Approach windows worth monitoring',
          subtitle:
              'Each card emphasizes the data points users care about first, while preserving enough technical depth to remain informative and credible.',
        ),
        const SizedBox(height: 18),
        for (var index = 0; index < objects.length; index++) ...[
          _NeoCard(object: objects[index])
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 60 * index),
                duration: AppConstants.motionMedium,
              )
              .slideY(begin: 0.03, end: 0),
          if (index != objects.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _NeoCard extends StatelessWidget {
  const _NeoCard({required this.object});

  final NearEarthObject object;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hazardColor = object.isHazardous
        ? AppColors.warning
        : AppColors.tertiary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: FrostedPanel(
        radius: AppConstants.radiusLarge,
        padding: const EdgeInsets.all(22),
        borderColor: hazardColor.withValues(alpha: 0.32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 880;

                final header = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppChip(
                          label: object.isHazardous
                              ? 'Potentially hazardous'
                              : 'Low hazard profile',
                          accent: hazardColor,
                          leading: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: hazardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        AppChip(label: 'Orbiting ${object.orbitingBody}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(object.name, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMMd().format(object.closeApproachDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                );

                final cta = object.nasaJplUrl.isEmpty
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: compact
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _launchUrl(context, object.nasaJplUrl),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('JPL details'),
                        ),
                      );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [header, const SizedBox(height: 16), cta],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: header),
                    const SizedBox(width: 16),
                    cta,
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 1020;
                final metrics = [
                  _TelemetryTile(
                    label: 'Estimated diameter',
                    value:
                        '${object.minDiameterMeters.toStringAsFixed(0)} - ${object.maxDiameterMeters.toStringAsFixed(0)} m',
                    accent: AppColors.primary,
                    helper:
                        'Average ${object.averageDiameterMeters.toStringAsFixed(0)} m',
                  ),
                  _TelemetryTile(
                    label: 'Relative velocity',
                    value:
                        '${object.relativeVelocityKilometersPerSecond.toStringAsFixed(2)} km/s',
                    accent: AppColors.secondary,
                    helper:
                        '${_toKilometersPerHour(object.relativeVelocityKilometersPerSecond).toStringAsFixed(0)} km/h',
                  ),
                  _TelemetryTile(
                    label: 'Miss distance',
                    value: _formatDistance(object.missDistanceKilometers),
                    accent: object.isHazardous
                        ? AppColors.warning
                        : AppColors.tertiary,
                    helper:
                        '${_toLunarDistances(object.missDistanceKilometers).toStringAsFixed(2)} lunar distances',
                  ),
                ];

                if (compact) {
                  return Column(
                    children: [
                      for (var index = 0; index < metrics.length; index++) ...[
                        metrics[index],
                        if (index != metrics.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var index = 0; index < metrics.length; index++) ...[
                      Expanded(child: metrics[index]),
                      if (index != metrics.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      _showLaunchError(context);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the JPL page right now.')),
    );
  }
}

class _TelemetryTile extends StatelessWidget {
  const _TelemetryTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.helper,
  });

  final String label;
  final String value;
  final Color accent;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            helper,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.helper,
  });

  final String label;
  final String value;
  final Color accent;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderColor: accent.withValues(alpha: 0.26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(helper, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

double _toKilometersPerHour(double kilometersPerSecond) {
  return kilometersPerSecond * 3600;
}

double _toLunarDistances(double kilometers) {
  const lunarDistanceKm = 384400;
  return kilometers / lunarDistanceKm;
}

String _formatDistance(double kilometers) {
  final formatter = NumberFormat.compact(locale: 'en_US');
  return '${formatter.format(kilometers)} km';
}

String _formatDistanceCompact(double kilometers) {
  final compact = NumberFormat.compact(locale: 'en_US', explicitSign: false);
  return '${compact.format(kilometers)} km';
}
