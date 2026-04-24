import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../../../../core/utils/trusted_external_url.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/translation_language_sheet.dart';
import '../../../apod/presentation/widgets/apod_fullscreen_viewer.dart';
import '../../domain/entities/nasa_media_item.dart';
import '../providers/nasa_media_playback_provider.dart';
import '../providers/nasa_media_translation_controller.dart';
import '../widgets/nasa_inline_video_player.dart';
import 'nasa_video_player_page.dart';

class NasaMediaDetailPage extends ConsumerWidget {
  const NasaMediaDetailPage({super.key, required this.item});

  final NasaMediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final heroTag = 'nasa-media-detail-${item.nasaId}';
    final translationTarget = NasaMediaTranslationTarget.fromItem(item);
    final translationProvider = nasaMediaTranslationControllerProvider(
      translationTarget,
    );

    ref.listen<NasaMediaTranslationNotice?>(
      translationProvider.select((state) => state.notice),
      (previous, next) {
        if (next == null || previous?.id == next.id) {
          return;
        }

        _showSnackBar(context, next);
      },
    );

    final translationState = ref.watch(translationProvider);

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
                      _MediaPreview(
                        item: item,
                        heroTag: heroTag,
                        title: translationState.displayedTitle,
                        description: translationState.displayedDescription,
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
                      _NasaMediaDetailTranslationPanel(
                        target: translationTarget,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        translationState.displayedTitle,
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        translationState.displayedDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.84),
                        ),
                      ),
                      // const SizedBox(height: 24),
                      // _EditorialPanel(item: item),
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

  void _showSnackBar(BuildContext context, NasaMediaTranslationNotice notice) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                notice.isError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: notice.isError ? AppColors.error : AppColors.tertiary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      );
  }
}

class _MediaPreview extends ConsumerWidget {
  const _MediaPreview({
    required this.item,
    required this.heroTag,
    required this.title,
    required this.description,
  });

  final NasaMediaItem item;
  final String heroTag;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.isVideo) {
      return _VideoPreview(item: item, title: title, description: description);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          SwipeBackPageRoute<void>(
            builder: (context) => ApodFullscreenViewer(
              imageUrl: item.previewUrl,
              heroTag: heroTag,
              title: title,
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
  const _VideoPreview({
    required this.item,
    required this.title,
    required this.description,
  });

  final NasaMediaItem item;
  final String title;
  final String description;

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

    return playbackUrlAsync.when(
      data: (playbackUrl) {
        if (playbackUrl == null || playbackUrl.isEmpty) {
          return _buildFramedStatus(
            _VideoStatusCard(
              posterUrl: item.previewUrl,
              eyebrow: 'NASA video entry',
              title:
                  'We found the record, but no playable stream was available.',
            ),
          );
        }

        // On web, video_player does not reliably initialize.
        // Show a card that opens the video directly in the browser.
        if (kIsWeb) {
          return _buildFramedStatus(
            _WebVideoCard(
              posterUrl: item.previewUrl,
              playbackUrl: playbackUrl,
              title: item.title,
            ),
          );
        }

        return NasaInlineVideoPlayer(
          playbackUrl: playbackUrl,
          posterUrl: item.previewUrl,
          controlsBelowVideo: true,
          onFullscreenPressed: () =>
              _openLargePlayer(context, playbackUrl: playbackUrl),
        );
      },
      loading: () => _buildFramedStatus(
        _VideoStatusCard(
          posterUrl: item.previewUrl,
          eyebrow: 'Preparing playback',
          title: 'Loading NASA video stream...',
          showLoader: true,
        ),
      ),
      error: (error, stackTrace) => _buildFramedStatus(
        _VideoStatusCard(
          posterUrl: item.previewUrl,
          eyebrow: 'Playback unavailable',
          title: 'The video could not be prepared inside the app yet.',
          actionLabel: 'Try again',
          onActionPressed: () {
            ref.invalidate(nasaVideoPlaybackUrlProvider(manifestUrl));
          },
        ),
      ),
    );
  }

  Widget _buildFramedStatus(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
      child: AspectRatio(aspectRatio: 16 / 9, child: child),
    );
  }

  void _openLargePlayer(BuildContext context, {required String playbackUrl}) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      SwipeBackPageRoute<void>(
        builder: (context) => NasaVideoPlayerPage(
          title: title,
          subtitle: description,
          playbackUrl: playbackUrl,
          posterUrl: item.previewUrl,
        ),
      ),
    );
  }
}

class _NasaMediaDetailTranslationPanel extends ConsumerWidget {
  const _NasaMediaDetailTranslationPanel({required this.target});

  final NasaMediaTranslationTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = nasaMediaTranslationControllerProvider(target);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final theme = Theme.of(context);
    final targetLanguage = TranslationLanguageOptions.fromCode(
      state.targetLanguageCode,
    );
    final isEnglish = targetLanguage == null || targetLanguage.isEnglish;
    final languageLabel = targetLanguage?.label ?? 'Language';
    final status = state.isTranslationActive && targetLanguage != null
        ? 'Translated: ${targetLanguage.label}'
        : isEnglish
        ? 'Original text'
        : 'Target: ${targetLanguage.label}';
    final primaryLabel = state.isTranslating
        ? 'Translating...'
        : state.isTranslationActive
        ? 'Original'
        : state.hasCurrentTranslation
        ? 'Translation'
        : isEnglish
        ? 'Language'
        : 'Translate';

    final primaryAction = state.isTranslating
        ? null
        : state.isTranslationActive
        ? controller.showOriginal
        : isEnglish
        ? () => _chooseLanguageAndTranslate(context, ref, target)
        : controller.translate;

    final icon = state.isTranslating
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.textPrimary,
            ),
          )
        : Icon(
            state.isTranslationActive
                ? Icons.article_outlined
                : Icons.translate_rounded,
            size: 18,
          );

    final primaryButton = state.isTranslationActive
        ? OutlinedButton.icon(
            onPressed: primaryAction,
            icon: icon,
            label: Text(primaryLabel),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              visualDensity: VisualDensity.compact,
            ),
          )
        : FilledButton.icon(
            onPressed: primaryAction,
            icon: icon,
            label: Text(primaryLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              visualDensity: VisualDensity.compact,
            ),
          );

    return FrostedPanel(
      radius: 18,
      blurSigma: 14,
      showSheen: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.5),
      borderColor: AppColors.tertiary.withValues(alpha: 0.12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 460;
          final languageButton = TextButton.icon(
            onPressed: state.isTranslating
                ? null
                : () => _chooseLanguageAndTranslate(context, ref, target),
            icon: const Icon(Icons.tune_rounded, size: 17),
            label: Text(compact ? 'Lang' : languageLabel),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 38),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
          );

          final statusRow = Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  size: 16,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statusRow,
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: primaryButton),
                    const SizedBox(width: 8),
                    languageButton,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: statusRow),
              const SizedBox(width: 10),
              primaryButton,
              const SizedBox(width: 4),
              languageButton,
            ],
          );
        },
      ),
    );
  }

  Future<void> _chooseLanguageAndTranslate(
    BuildContext context,
    WidgetRef ref,
    NasaMediaTranslationTarget target,
  ) async {
    final picked = await showTranslationLanguageSheet(context, ref);
    if (picked == null || !context.mounted) {
      return;
    }

    if (picked.isEnglish) {
      ref
          .read(nasaMediaTranslationControllerProvider(target).notifier)
          .showOriginal();
      return;
    }

    await ref
        .read(nasaMediaTranslationControllerProvider(target).notifier)
        .translate();
  }
}

/// Web-only widget: renders a poster with an "Open Video" button
/// since video_player does not reliably run in a browser context.
class _WebVideoCard extends StatelessWidget {
  const _WebVideoCard({
    required this.posterUrl,
    required this.playbackUrl,
    required this.title,
  });

  final String posterUrl;
  final String playbackUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (posterUrl.isNotEmpty)
          PremiumNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.26),
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 38,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FrostedPanel(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  backgroundColor: AppColors.surfaceElevated.withValues(
                    alpha: 0.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NASA Video',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to open in browser for the best playback experience.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => _openInBrowser(context),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open Video'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = sanitizeTrustedExternalUri(
      playbackUrl,
      allowedHosts: TrustedHostSets.nasaAndVideoHosts,
    );
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this video URL.')),
        );
      }
      return;
    }

    final launched = await launchExternalUri(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the NASA video.')),
      );
    }
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

// class _EditorialPanel extends StatelessWidget {
//   const _EditorialPanel({required this.item});
//
//   final NasaMediaItem item;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SectionHeading(
//           eyebrow: 'Context',
//           title: 'Why this result stands out',
//           subtitle:
//               'NASA media search returns a broad archive. This detail view keeps the media immersive while surfacing the identifiers and creators that give the entry provenance.',
//         ),
//         const SizedBox(height: 18),
//         FrostedPanel(
//           padding: const EdgeInsets.all(22),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Collection notes', style: theme.textTheme.titleLarge),
//               const SizedBox(height: 12),
//               Text(
//                 'Bookmarks now persist locally, so saved archive results can survive app restarts and start building toward a fuller personal collection.',
//                 style: theme.textTheme.bodyLarge,
//               ),
//               if (item.hasKeywords) ...[
//                 const SizedBox(height: 20),
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 10,
//                   children: [
//                     for (final keyword in item.keywords.take(8))
//                       AppChip(label: keyword),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

String _typeLabel(NasaMediaType type) {
  return switch (type) {
    NasaMediaType.image => 'Image',
    NasaMediaType.video => 'Video',
    NasaMediaType.audio => 'Audio',
    NasaMediaType.unknown => 'Media',
  };
}
