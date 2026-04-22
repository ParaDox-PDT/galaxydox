import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/apod_item.dart';
import '../utils/apod_video_launcher.dart';
import 'apod_fullscreen_viewer.dart';

class ApodMediaPreview extends StatelessWidget {
  const ApodMediaPreview({super.key, required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isVideo) {
      return _ApodVideoPreview(item: item);
    }

    return _ApodImagePreview(item: item);
  }
}

class _ApodImagePreview extends StatelessWidget {
  const _ApodImagePreview({required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'apod-image-${item.date.toIso8601String()}';
    final imageUrl = item.preferredImageUrl;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          SwipeBackPageRoute<void>(
            builder: (context) => ApodFullscreenViewer(
              imageUrl: imageUrl,
              heroTag: heroTag,
              title: item.title,
              subtitle: 'Tap and pinch to explore the image in detail.',
            ),
          ),
        );
      },
      child: Container(
        height: 420,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.28),
              blurRadius: 36,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: PremiumNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.heroOverlay),
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: FrostedPanel(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  backgroundColor: AppColors.surfaceElevated.withValues(
                    alpha: 0.4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_out_map_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Open full screen',
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 20,
                child: Row(
                  children: [
                    Expanded(
                      child: FrostedPanel(
                        radius: 24,
                        padding: const EdgeInsets.all(18),
                        backgroundColor: AppColors.surfaceElevated.withValues(
                          alpha: 0.44,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.hasHdImage
                                  ? 'HD image available'
                                  : 'NASA image',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the image to explore it at full size.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.78,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApodVideoPreview extends StatelessWidget {
  const _ApodVideoPreview({required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = resolveApodVideoPosterUrl(item);

    return GestureDetector(
      onTap: () => openApodVideoPlayer(context, item: item),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.26),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnailUrl != null)
                PremiumNetworkImage(imageUrl: thumbnailUrl, fit: BoxFit.cover)
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.storySurface(
                      accent: AppColors.secondary,
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.heroOverlay),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 22,
                child: FrostedPanel(
                  radius: 22,
                  padding: const EdgeInsets.all(10),
                  backgroundColor: AppColors.surfaceElevated.withValues(
                    alpha: 0.48,
                  ),
                  child: FilledButton.icon(
                    onPressed: () => openApodVideoPlayer(context, item: item),
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                    label: const Text('Open video'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
