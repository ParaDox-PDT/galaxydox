import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/app_chip.dart';
import '../../../widgets/frosted_panel.dart';
import '../../../widgets/premium_network_image.dart';
import '../../data/models/bookmark_item.dart';
import '../bookmark_navigation.dart';
import '../providers/bookmark_controller.dart';

class BookmarkContentCard extends ConsumerWidget {
  const BookmarkContentCard({super.key, required this.bookmark});

  final BookmarkItem bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              HapticFeedback.selectionClick();
              await openBookmarkDetail(context, bookmark);
            },
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
                    final preview = _BookmarkPreview(bookmark: bookmark);
                    final content = Padding(
                      padding: EdgeInsets.only(left: compact ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              AppChip(label: bookmark.contentType.label),
                              if ((bookmark.metadataPrimary ?? '').isNotEmpty)
                                AppChip(label: bookmark.metadataPrimary!),
                              if (bookmark.date != null)
                                AppChip(
                                  label: DateFormat.yMMMd().format(
                                    bookmark.date!,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bookmark.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                          if ((bookmark.subtitle ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              bookmark.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            bookmark.description,
                            maxLines: compact ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: () async {
                                  HapticFeedback.selectionClick();
                                  await openBookmarkDetail(context, bookmark);
                                },
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('Open'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  HapticFeedback.selectionClick();
                                  final result = await ref
                                      .read(bookmarkControllerProvider.notifier)
                                      .remove(bookmark.id);

                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result.message)),
                                  );
                                },
                                icon: const Icon(Icons.bookmark_remove_rounded),
                                label: const Text('Remove'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          preview,
                          const SizedBox(height: 16),
                          content,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 240, child: preview),
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
}

class _BookmarkPreview extends StatelessWidget {
  const _BookmarkPreview({required this.bookmark});

  final BookmarkItem bookmark;

  @override
  Widget build(BuildContext context) {
    final hasImage = bookmark.imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              PremiumNetworkImage(
                imageUrl: bookmark.imageUrl,
                fit: BoxFit.cover,
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceElevated,
                      AppColors.surfaceStrong,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.primary.withValues(alpha: 0.72),
                  size: 38,
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: FrostedPanel(
                radius: 18,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                backgroundColor: AppColors.surfaceElevated.withValues(
                  alpha: 0.42,
                ),
                child: Text(
                  bookmark.metadataSecondary ??
                      DateFormat.yMMMd().format(bookmark.savedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
