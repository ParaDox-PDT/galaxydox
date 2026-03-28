import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/trusted_external_url.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../domain/entities/near_earth_object.dart';

class NeoDetailPage extends StatelessWidget {
  const NeoDetailPage({super.key, required this.object});

  final NearEarthObject object;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hazardColor = object.isHazardous
        ? AppColors.warning
        : AppColors.tertiary;

    return SpaceScaffold(
      bottomSafeArea: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidthCompact,
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
                        title: object.name,
                        subtitle:
                            'Close approach on ${DateFormat.yMMMMd().format(object.closeApproachDate)}',
                        actions: [
                          BookmarkButton(
                            bookmark: BookmarkMapper.fromNearEarthObject(
                              object,
                            ),
                            unsavedLabel: 'Bookmark',
                            savedLabel: 'Bookmarked',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.stackGap),
                      FrostedPanel(
                        padding: const EdgeInsets.all(24),
                        borderColor: hazardColor.withValues(alpha: 0.28),
                        child: Column(
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
                                ),
                                AppChip(
                                  label: 'Orbiting ${object.orbitingBody}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Approach intelligence',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This saved asteroid entry keeps the high-signal telemetry front and center so users can revisit notable flybys without requerying the feed.',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 22),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final compact = constraints.maxWidth < 920;
                                final tiles = [
                                  _NeoMetricTile(
                                    label: 'Estimated diameter',
                                    value:
                                        '${object.minDiameterMeters.toStringAsFixed(0)} - ${object.maxDiameterMeters.toStringAsFixed(0)} m',
                                    accent: AppColors.primary,
                                    helper:
                                        'Average ${object.averageDiameterMeters.toStringAsFixed(0)} m',
                                  ),
                                  _NeoMetricTile(
                                    label: 'Relative velocity',
                                    value:
                                        '${object.relativeVelocityKilometersPerSecond.toStringAsFixed(2)} km/s',
                                    accent: AppColors.secondary,
                                    helper:
                                        '${(object.relativeVelocityKilometersPerSecond * 3600).toStringAsFixed(0)} km/h',
                                  ),
                                  _NeoMetricTile(
                                    label: 'Miss distance',
                                    value:
                                        '${NumberFormat.compact(locale: 'en_US').format(object.missDistanceKilometers)} km',
                                    accent: hazardColor,
                                    helper:
                                        '${(object.missDistanceKilometers / 384400).toStringAsFixed(2)} lunar distances',
                                  ),
                                ];

                                if (compact) {
                                  return Column(
                                    children: [
                                      for (
                                        var index = 0;
                                        index < tiles.length;
                                        index++
                                      ) ...[
                                        tiles[index],
                                        if (index != tiles.length - 1)
                                          const SizedBox(height: 12),
                                      ],
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < tiles.length;
                                      index++
                                    ) ...[
                                      Expanded(child: tiles[index]),
                                      if (index != tiles.length - 1)
                                        const SizedBox(width: 12),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.stackGap),
                      const SectionHeading(
                        eyebrow: 'Actions',
                        title: 'Continue the investigation',
                        subtitle:
                            'Bookmarks keep the object close at hand while preserving a clean route back to NASA’s official JPL context when you need the external reference.',
                      ),
                      const SizedBox(height: 18),
                      FrostedPanel(
                        padding: const EdgeInsets.all(22),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            BookmarkButton(
                              bookmark: BookmarkMapper.fromNearEarthObject(
                                object,
                              ),
                            ),
                            if (object.nasaJplUrl.isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _launchUrl(context, object.nasaJplUrl),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('Open JPL details'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String rawUrl) async {
    final uri = sanitizeTrustedExternalUri(
      rawUrl,
      allowedHosts: TrustedHostSets.nasaHosts,
    );
    if (uri == null) {
      _showLaunchError(context);
      return;
    }

    final launched = await launchExternalUri(uri);
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

class _NeoMetricTile extends StatelessWidget {
  const _NeoMetricTile({
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
