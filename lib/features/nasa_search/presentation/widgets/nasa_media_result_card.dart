import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/nasa_media_item.dart';
import '../providers/nasa_media_translation_controller.dart';

final DateFormat _nasaMediaDateFormatter = DateFormat.yMMMd();

class NasaMediaResultCard extends StatelessWidget {
  const NasaMediaResultCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final NasaMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _ListCard(item: item, onTap: onTap),
    );
  }
}

class _ListCard extends ConsumerWidget {
  const _ListCard({required this.item, required this.onTap});

  final NasaMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
    final targetLanguage = TranslationLanguageOptions.fromCode(
      translationState.targetLanguageCode,
    );
    final subtitle =
        translationState.isTranslationActive && targetLanguage != null
        ? 'Translated to ${targetLanguage.label} | ${_buildSubtitle(item)}'
        : _buildSubtitle(item);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceElevated.withValues(alpha: 0.92),
                    AppColors.surface.withValues(alpha: 0.98),
                  ],
                ),
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 760;
                    final image = SizedBox(
                      height: compact ? 220 : 132,
                      width: compact ? double.infinity : 216,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PremiumNetworkImage(
                              imageUrl: item.previewUrl,
                              fit: BoxFit.cover,
                            ),
                            if (item.mediaType == NasaMediaType.video)
                              const Center(child: _VideoPlayBadge()),
                          ],
                        ),
                      ),
                    );

                    final content = Padding(
                      padding: EdgeInsets.only(left: compact ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _TypePill(type: item.mediaType),
                              _MetadataPill(label: item.center),
                              BookmarkButton(
                                bookmark: BookmarkMapper.fromNasaMediaItem(
                                  item,
                                ),
                                savedLabel: 'Bookmarked',
                                unsavedLabel: 'Bookmark',
                                variant: BookmarkButtonVariant.icon,
                              ),
                              _SmallTranslationButton(
                                target: translationTarget,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            translationState.displayedTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            translationState.displayedDescription,
                            maxLines: compact ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _OpenDetailsRow(theme: theme),
                        ],
                      ),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [image, const SizedBox(height: 16), content],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        image,
                        Expanded(child: content),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }
}

class _OpenDetailsRow extends StatelessWidget {
  const _OpenDetailsRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Open details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_outward_rounded, color: AppColors.secondary),
      ],
    );
  }
}

class _SmallTranslationButton extends ConsumerWidget {
  const _SmallTranslationButton({required this.target});

  final NasaMediaTranslationTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = nasaMediaTranslationControllerProvider(target);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final targetLanguage = TranslationLanguageOptions.fromCode(
      state.targetLanguageCode,
    );

    final label = state.isTranslating
        ? 'Translating'
        : state.isTranslationActive
        ? 'Original'
        : state.hasCurrentTranslation
        ? 'View'
        : 'Translate';
    final tooltip = state.isTranslationActive
        ? 'View original NASA text'
        : targetLanguage == null || targetLanguage.isEnglish
        ? 'Choose another translation language in Settings'
        : 'Translate to ${targetLanguage.label}';

    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: state.isTranslating
            ? null
            : state.isTranslationActive
            ? controller.showOriginal
            : controller.translate,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 38),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          foregroundColor: AppColors.tertiary,
          side: BorderSide(color: AppColors.tertiary.withValues(alpha: 0.34)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        icon: state.isTranslating
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : const Icon(Icons.translate_rounded, size: 16),
        label: Text(label),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});

  final NasaMediaType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      NasaMediaType.image => ('Image', AppColors.primary),
      NasaMediaType.video => ('Video', AppColors.secondary),
      NasaMediaType.audio => ('Audio', AppColors.tertiary),
      NasaMediaType.unknown => ('Media', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(label),
    );
  }
}

class _VideoPlayBadge extends StatelessWidget {
  const _VideoPlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.32),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.2)),
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        size: 34,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Text(label),
    );
  }
}

String _buildSubtitle(NasaMediaItem item) {
  final pieces = <String>[
    if (item.dateCreated != null)
      _nasaMediaDateFormatter.format(item.dateCreated!),
    if ((item.photographer ?? '').isNotEmpty) item.photographer!,
  ];

  if (pieces.isEmpty) {
    return item.center;
  }

  return pieces.join(' | ');
}
