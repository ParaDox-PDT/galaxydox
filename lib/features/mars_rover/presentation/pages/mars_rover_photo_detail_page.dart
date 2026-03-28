import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/mars_rover_photo.dart';

class MarsRoverPhotoDetailPage extends StatelessWidget {
  const MarsRoverPhotoDetailPage({
    super.key,
    required this.photo,
    required this.heroTag,
  });

  final MarsRoverPhoto photo;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4.5,
            child: Center(
              child: Hero(
                tag: heroTag,
                child: PremiumNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            child: _TopButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: BookmarkButton(
              bookmark: BookmarkMapper.fromMarsRoverPhoto(photo),
              savedLabel: 'Bookmarked',
              unsavedLabel: 'Bookmark',
              variant: BookmarkButtonVariant.icon,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(photo.roverName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${photo.cameraFullName} | ${DateFormat.yMMMMd().format(photo.earthDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: IconButton(onPressed: onPressed, icon: Icon(icon)),
      ),
    );
  }
}
