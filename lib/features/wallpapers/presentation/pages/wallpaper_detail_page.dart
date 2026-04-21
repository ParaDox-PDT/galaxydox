import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/wallpaper_download_service.dart';
import '../../domain/wallpaper_entity.dart';
import '../providers/wallpapers_provider.dart';

class WallpaperDetailPage extends ConsumerWidget {
  const WallpaperDetailPage({
    required this.wallpaperId,
    this.initialWallpaper,
    super.key,
  });

  final String wallpaperId;
  final WallpaperEntity? initialWallpaper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialWallpaper != null) {
      return _WallpaperDetailContent(wallpaper: initialWallpaper!);
    }

    final wallpaperAsync = ref.watch(wallpaperByIdProvider(wallpaperId));
    return wallpaperAsync.when(
      loading: () => const _WallpaperDetailPlaceholder(
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      error: (error, _) => _WallpaperDetailPlaceholder(
        child: _WallpaperDetailMessage(
          title: 'Unable to open wallpaper',
          message: error is AppException
              ? error.message
              : 'This wallpaper could not be loaded right now.',
        ),
      ),
      data: (wallpaper) {
        if (wallpaper == null) {
          return const _WallpaperDetailPlaceholder(
            child: _WallpaperDetailMessage(
              title: 'Wallpaper not found',
              message:
                  'The related wallpaper document was not found in Firebase.',
            ),
          );
        }

        return _WallpaperDetailContent(wallpaper: wallpaper);
      },
    );
  }
}

class _WallpaperDetailContent extends StatefulWidget {
  const _WallpaperDetailContent({required this.wallpaper});

  final WallpaperEntity wallpaper;

  @override
  State<_WallpaperDetailContent> createState() =>
      _WallpaperDetailContentState();
}

class _WallpaperDetailContentState extends State<_WallpaperDetailContent> {
  static const _downloadService = WallpaperDownloadService();

  late final PhotoViewController _photoController;
  late final PhotoViewScaleStateController _scaleStateController;
  bool _isDownloading = false;
  double? _downloadProgress;

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

    final imageUri = Uri.tryParse(widget.wallpaper.imageUrl.trim());
    if (imageUri == null || !imageUri.hasScheme) {
      _showSnackBar(
        'This wallpaper does not have a valid download link.',
        icon: Icons.error_rounded,
        color: AppColors.error,
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final result = await _downloadService.download(
        imageUri: imageUri,
        fileName: _buildFileName(imageUri),
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _downloadProgress = progress);
        },
      );

      if (!mounted) return;

      HapticFeedback.lightImpact();
      _showSnackBar(
        result.message,
        icon: Icons.check_circle_rounded,
        color: AppColors.tertiary,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error is AppException
          ? error.message
          : 'Download failed. Please try again.';
      _showSnackBar(message, icon: Icons.error_rounded, color: AppColors.error);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = null;
        });
      }
    }
  }

  Future<void> _shareWallpaper() async {
    await SharePlus.instance.share(
      ShareParams(text: widget.wallpaper.imageUrl),
    );
  }

  String _buildFileName(Uri imageUri) {
    final safeTitle = widget.wallpaper.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final extension = _resolveExtension(imageUri);
    return 'wallpaper_${safeTitle}_${widget.wallpaper.id}$extension';
  }

  String _resolveExtension(Uri imageUri) {
    if (imageUri.pathSegments.isEmpty) {
      return '.jpg';
    }

    final lastSegment = imageUri.pathSegments.last;
    final dotIndex = lastSegment.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == lastSegment.length - 1) {
      return '.jpg';
    }

    final extension = lastSegment.substring(dotIndex).toLowerCase();
    if (!RegExp(r'^\.[a-z0-9]{2,5}$').hasMatch(extension)) {
      return '.jpg';
    }

    return extension;
  }

  void _showSnackBar(
    String message, {
    required IconData icon,
    required Color color,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
                      value: _downloadProgress != null && _downloadProgress! > 0
                          ? _downloadProgress
                          : null,
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
      body: Hero(
        tag: 'wallpaper-hero-${widget.wallpaper.id}',
        child: PhotoView(
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
      ),
    );
  }
}

class _WallpaperDetailPlaceholder extends StatelessWidget {
  const _WallpaperDetailPlaceholder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      ),
      body: child,
    );
  }
}

class _WallpaperDetailMessage extends StatelessWidget {
  const _WallpaperDetailMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wallpaper_rounded,
                size: 36,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
