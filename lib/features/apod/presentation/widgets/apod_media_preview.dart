import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/apod_item.dart';
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
          MaterialPageRoute<void>(
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
    final theme = Theme.of(context);
    final videoUri = Uri.tryParse(item.url);
    final thumbnailUrl = _buildYoutubeThumbnail(videoUri) ?? item.thumbnailUrl;

    return Container(
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
            Center(
              child: GestureDetector(
                onTap: () => _launchVideo(context),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textPrimary.withValues(alpha: 0.14),
                    border: Border.all(
                      color: AppColors.textPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 42,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: FrostedPanel(
                radius: 26,
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.surfaceElevated.withValues(
                  alpha: 0.42,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NASA video entry',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This APOD entry is a video. Launch it in your browser for the full viewing experience.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _launchVideo(context),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open video'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(BuildContext context) async {
    final uri = Uri.tryParse(item.url);
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
      const SnackBar(content: Text('Unable to open the APOD video right now.')),
    );
  }

  String? _buildYoutubeThumbnail(Uri? uri) {
    if (uri == null) {
      return null;
    }

    final host = uri.host.toLowerCase();
    String? videoId;

    if (host.contains('youtube.com')) {
      videoId = uri.queryParameters['v'];
      if (videoId == null && uri.pathSegments.isNotEmpty) {
        final embedIndex = uri.pathSegments.indexOf('embed');
        if (embedIndex != -1 && embedIndex + 1 < uri.pathSegments.length) {
          videoId = uri.pathSegments[embedIndex + 1];
        }
      }
    } else if (host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      videoId = uri.pathSegments.first;
    }

    if (videoId == null || videoId.isEmpty) {
      return null;
    }

    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }
}
