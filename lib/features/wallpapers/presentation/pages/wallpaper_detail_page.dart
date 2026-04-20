import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
  bool _isDownloading = false;
  double _downloadProgress = 0;

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

  Future<void> _downloadWallpaper() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeTitle = widget.wallpaper.title
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .toLowerCase();
      final fileName = 'wallpaper_${safeTitle}_${widget.wallpaper.id}.jpg';
      final filePath = '${dir.path}/$fileName';

      await Dio().download(
        widget.wallpaper.imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (mounted) {
        HapticFeedback.lightImpact();
        _showSnackBar(
          'Saved to your device',
          icon: Icons.check_circle_rounded,
          color: AppColors.tertiary,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar(
          'Download failed. Please try again.',
          icon: Icons.error_rounded,
          color: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0;
        });
      }
    }
  }

  Future<void> _shareWallpaper() async {
    await SharePlus.instance.share(
      ShareParams(text: widget.wallpaper.imageUrl),
    );
  }

  void _showSnackBar(
    String message, {
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
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
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            foregroundColor: Colors.white,
          ),
        ),
        title: Text(
          widget.wallpaper.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _isDownloading ? null : _downloadWallpaper,
            icon: _isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _shareWallpaper,
            icon: const Icon(Icons.share_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
