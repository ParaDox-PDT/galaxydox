import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../domain/wallpaper_entity.dart';

class WallpaperDetailPage extends StatefulWidget {
  const WallpaperDetailPage({required this.wallpaper, super.key});

  final WallpaperEntity wallpaper;

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  late final PhotoViewController _photoController;
  late final PhotoViewScaleStateController _scaleStateController;

  @override
  void initState() {
    super.initState();
    _photoController = PhotoViewController();
    _scaleStateController = PhotoViewScaleStateController();
  }

  @override
  void dispose() {
    _photoController.dispose();
    _scaleStateController.dispose();
    super.dispose();
  }

  PhotoViewScaleState _scaleStateCycle(PhotoViewScaleState actual) {
    if (actual == PhotoViewScaleState.initial ||
        actual == PhotoViewScaleState.covering) {
      return PhotoViewScaleState.originalSize;
    }
    return PhotoViewScaleState.initial;
  }

  void _handleScaleEnd(
    BuildContext context,
    ScaleEndDetails details,
    PhotoViewControllerValue controllerValue,
  ) {
    final verticalVelocity = details.velocity.pixelsPerSecond.dy;
    final horizontalVelocity = details.velocity.pixelsPerSecond.dx;
    final currentScale = controllerValue.scale ?? 1;
    final isAtBaseScale = currentScale <= 1.05;

    if (!isAtBaseScale) return;
    if (verticalVelocity < 900) return;
    if (verticalVelocity.abs() <= horizontalVelocity.abs()) return;

    HapticFeedback.selectionClick();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return SpaceScaffold(
      topSafeArea: false,
      bottomSafeArea: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: PhotoView(
        controller: _photoController,
        scaleStateController: _scaleStateController,
        imageProvider: CachedNetworkImageProvider(widget.wallpaper.imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        initialScale: PhotoViewComputedScale.contained,
        enablePanAlways: true,
        strictScale: true,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        scaleStateCycle: _scaleStateCycle,
        onScaleEnd: _handleScaleEnd,
        loadingBuilder: (context, event) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: AppColors.textPrimary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 34,
              color: AppColors.textMuted,
            ),
          );
        },
      ),
    );
  }
}
