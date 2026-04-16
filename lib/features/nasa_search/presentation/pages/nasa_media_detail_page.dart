import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../apod/presentation/widgets/apod_fullscreen_viewer.dart';
import '../../domain/entities/nasa_media_item.dart';
import 'nasa_video_player_page.dart';
import '../providers/nasa_media_playback_provider.dart';
import '../widgets/nasa_inline_video_player.dart';

class NasaMediaDetailPage extends ConsumerWidget {
  const NasaMediaDetailPage({super.key, required this.item});

  final NasaMediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final heroTag = 'nasa-media-detail-${item.nasaId}';

    return SpaceScaffold(
      bottomSafeArea: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: item.isVideo
                      ? AppConstants.contentMaxWidth
                      : AppConstants.contentMaxWidthCompact,
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
                            bookmark: BookmarkMapper.fromNasaMediaItem(item),
                            unsavedLabel: 'Bookmark',
                            savedLabel: 'Bookmarked',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _MediaPreview(item: item, heroTag: heroTag),
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
                      _EditorialPanel(item: item),
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

class _MediaPreview extends ConsumerWidget {
  const _MediaPreview({required this.item, required this.heroTag});

  final NasaMediaItem item;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.isVideo) {
      return _VideoPreview(item: item);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ApodFullscreenViewer(
              imageUrl: item.previewUrl,
              heroTag: heroTag,
              title: item.title,
              subtitle: 'Tap and pinch to explore the image in detail.',
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Hero(
            tag: heroTag,
            child: PremiumNetworkImage(
              imageUrl: item.previewUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends ConsumerWidget {
  const _VideoPreview({required this.item});

  final NasaMediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifestUrl = item.resolvedAssetManifestUrl;

    if (manifestUrl == null || manifestUrl.isEmpty) {
      return _VideoStatusCard(
        posterUrl: item.previewUrl,
        eyebrow: 'NASA video entry',
        title: 'Playable video asset was not provided for this result.',
      );
    }

    final playbackUrlAsync = ref.watch(
      nasaVideoPlaybackUrlProvider(manifestUrl),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: playbackUrlAsync.when(
          data: (playbackUrl) {
            if (playbackUrl == null || playbackUrl.isEmpty) {
              return _VideoStatusCard(
                posterUrl: item.previewUrl,
                eyebrow: 'NASA video entry',
                title:
                    'We found the record, but no playable stream was available.',
              );
            }

            return NasaInlineVideoPlayer(
              playbackUrl: playbackUrl,
              posterUrl: item.previewUrl,
              onFullscreenPressed: () =>
                  _openLargePlayer(context, playbackUrl: playbackUrl),
            );
          },
          loading: () => _VideoStatusCard(
            posterUrl: item.previewUrl,
            eyebrow: 'Preparing playback',
            title: 'Loading NASA video stream...',
            showLoader: true,
          ),
          error: (error, stackTrace) => _VideoStatusCard(
            posterUrl: item.previewUrl,
            eyebrow: 'Playback unavailable',
            title: 'The video could not be prepared inside the app yet.',
            actionLabel: 'Try again',
            onActionPressed: () {
              ref.invalidate(nasaVideoPlaybackUrlProvider(manifestUrl));
            },
          ),
        ),
      ),
    );
  }

  void _openLargePlayer(BuildContext context, {required String playbackUrl}) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NasaVideoPlayerPage(
          title: item.title,
          subtitle: item.description,
          playbackUrl: playbackUrl,
          posterUrl: item.previewUrl,
        ),
      ),
    );
  }
}

class _VideoStatusCard extends StatelessWidget {
  const _VideoStatusCard({
    required this.posterUrl,
    required this.eyebrow,
    required this.title,
    this.showLoader = false,
    this.actionLabel,
    this.onActionPressed,
  });

  final String posterUrl;
  final String eyebrow;
  final String title;
  final bool showLoader;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: FrostedPanel(
            radius: 26,
            padding: const EdgeInsets.all(22),
            backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.44),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLoader)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: CircularProgressIndicator(),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 34,
                      color: AppColors.textPrimary,
                    ),
                  ),
                Text(
                  eyebrow,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.secondary),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (actionLabel != null && onActionPressed != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onActionPressed,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
              'NASA media search returns a broad archive. This detail view keeps the media immersive while surfacing the identifiers and creators that give the entry provenance.',
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
