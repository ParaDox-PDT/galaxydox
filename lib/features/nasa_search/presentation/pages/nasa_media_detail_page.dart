import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/metadata_row.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../domain/entities/nasa_media_item.dart';

class NasaMediaDetailPage extends StatelessWidget {
  const NasaMediaDetailPage({super.key, required this.item});

  final NasaMediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkId = 'search:${item.nasaId}';

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
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back'),
                          ),
                          BookmarkButton(
                            bookmarkId: bookmarkId,
                            unsavedLabel: 'Bookmark',
                            savedLabel: 'Bookmarked',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusXLarge,
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: PremiumNetworkImage(
                            imageUrl: item.previewUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AppChip(label: item.center),
                          AppChip(label: _typeLabel(item.mediaType)),
                          if (item.dateCreated != null)
                            AppChip(
                              label: DateFormat.yMMMMd().format(
                                item.dateCreated!,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(item.title, style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.84),
                        ),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 980;
                          final metadata = _MetadataPanel(item: item);
                          final editorial = _EditorialPanel(item: item);

                          if (compact) {
                            return Column(
                              children: [
                                metadata,
                                const SizedBox(height: 18),
                                editorial,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: metadata),
                              const SizedBox(width: 18),
                              Expanded(flex: 3, child: editorial),
                            ],
                          );
                        },
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
}

class _MetadataPanel extends StatelessWidget {
  const _MetadataPanel({required this.item});

  final NasaMediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metadata', style: theme.textTheme.titleLarge),
          const SizedBox(height: 18),
          MetadataRow(label: 'NASA ID', value: item.nasaId),
          const SizedBox(height: 12),
          MetadataRow(label: 'Center', value: item.center),
          const SizedBox(height: 12),
          MetadataRow(label: 'Type', value: _typeLabel(item.mediaType)),
          if ((item.photographer ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            MetadataRow(label: 'Photographer', value: item.photographer!),
          ],
          if ((item.secondaryCreator ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            MetadataRow(label: 'Creator', value: item.secondaryCreator!),
          ],
        ],
      ),
    );
  }
}

class _EditorialPanel extends StatelessWidget {
  const _EditorialPanel({required this.item});

  final NasaMediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Context',
          title: 'Why this result stands out',
          subtitle:
              'NASA media search returns a broad archive. This detail view keeps the image immersive while surfacing the identifiers and creators that give the entry provenance.',
        ),
        const SizedBox(height: 18),
        FrostedPanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Collection notes', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Bookmarks now persist locally, so saved archive results can survive app restarts and start building toward a fuller personal collection.',
                style: theme.textTheme.bodyLarge,
              ),
              if (item.hasKeywords) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final keyword in item.keywords.take(8))
                      AppChip(label: keyword),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _typeLabel(NasaMediaType type) {
  return switch (type) {
    NasaMediaType.image => 'Image',
    NasaMediaType.video => 'Video',
    NasaMediaType.audio => 'Audio',
    NasaMediaType.unknown => 'Media',
  };
}
