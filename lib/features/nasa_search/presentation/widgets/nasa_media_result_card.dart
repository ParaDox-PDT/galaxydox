import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/nasa_media_item.dart';
import '../providers/nasa_search_controller.dart';

class NasaMediaResultCard extends StatelessWidget {
  const NasaMediaResultCard({
    super.key,
    required this.item,
    required this.viewMode,
    required this.onTap,
  });

  final NasaMediaItem item;
  final NasaSearchViewMode viewMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return viewMode == NasaSearchViewMode.grid
        ? _GridCard(item: item, onTap: onTap)
        : _ListCard(item: item, onTap: onTap);
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item, required this.onTap});

  final NasaMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 220;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.24),
                blurRadius: 34,
                offset: const Offset(0, 22),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: compact ? 5 : 6,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PremiumNetworkImage(
                              imageUrl: item.previewUrl,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: _TypePill(type: item.mediaType),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: BookmarkButton(
                                bookmark: BookmarkMapper.fromNasaMediaItem(
                                  item,
                                ),
                                savedLabel: 'Bookmarked',
                                unsavedLabel: 'Bookmark',
                                variant: BookmarkButtonVariant.icon,
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.52,
                                ),
                                child: FrostedPanel(
                                  radius: 16,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  backgroundColor: AppColors.surfaceElevated
                                      .withValues(alpha: 0.36),
                                  child: Text(
                                    item.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: compact ? 6 : 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: compact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _buildSubtitle(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Text(
                                  item.description,
                                  maxLines: compact ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _OpenDetailsRow(theme: theme),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.item, required this.onTap});

  final NasaMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        child: PremiumNetworkImage(
                          imageUrl: item.previewUrl,
                          fit: BoxFit.cover,
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _buildSubtitle(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.description,
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
    if (item.dateCreated != null) DateFormat.yMMMd().format(item.dateCreated!),
    if ((item.photographer ?? '').isNotEmpty) item.photographer!,
  ];

  if (pieces.isEmpty) {
    return item.center;
  }

  return pieces.join(' | ');
}
