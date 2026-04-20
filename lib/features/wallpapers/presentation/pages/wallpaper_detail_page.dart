import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../domain/wallpaper_entity.dart';

class WallpaperDetailPage extends StatefulWidget {
  const WallpaperDetailPage({required this.wallpaper, super.key});

  final WallpaperEntity wallpaper;

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

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
            setState(() {
              _downloadProgress = received / total;
            });
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

  @override
  Widget build(BuildContext context) {
    final wallpaper = widget.wallpaper;
    final dateText = wallpaper.createdAt != null
        ? DateFormat.yMMMMd().format(wallpaper.createdAt!)
        : null;

    return SpaceScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4.5,
            panEnabled: true,
            clipBehavior: Clip.none,
            child: SizedBox.expand(
              child: PremiumNetworkImage(
                imageUrl: wallpaper.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.shadow.withValues(alpha: 0.42),
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.shadow.withValues(alpha: 0.28),
                    AppColors.background.withValues(alpha: 0.82),
                  ],
                  stops: const [0, 0.12, 0.56, 0.76, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
              child: Column(
                children: [
                  _TopActionBar(
                    isDownloading: _isDownloading,
                    downloadProgress: _downloadProgress,
                    onBack: () => Navigator.of(context).maybePop(),
                    onDownload: _downloadWallpaper,
                    onShare: _shareWallpaper,
                  ).animate().fadeIn(duration: AppConstants.motionMedium),
                  const Spacer(),
                  _BottomMetadata(title: wallpaper.title, dateText: dateText)
                      .animate()
                      .fadeIn(delay: 80.ms, duration: AppConstants.motionMedium)
                      .slideY(begin: 0.06, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActionBar extends StatelessWidget {
  const _TopActionBar({
    required this.isDownloading,
    required this.downloadProgress,
    required this.onBack,
    required this.onDownload,
    required this.onShare,
  });

  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback onBack;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OverlayActionButton(
          onPressed: onBack,
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
        const Spacer(),
        _OverlayActionButton(
          onPressed: isDownloading ? null : onDownload,
          child: isDownloading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: downloadProgress > 0 ? downloadProgress : null,
                    strokeWidth: 2.2,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Icon(
                  Icons.download_rounded,
                  color: AppColors.textPrimary,
                  size: 21,
                ),
        ),
        const SizedBox(width: 10),
        _OverlayActionButton(
          onPressed: onShare,
          child: const Icon(
            Icons.share_rounded,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),
      ],
    );
  }
}

class _OverlayActionButton extends StatelessWidget {
  const _OverlayActionButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        onTap: onPressed,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}

class _BottomMetadata extends StatelessWidget {
  const _BottomMetadata({required this.title, required this.dateText});

  final String title;
  final String? dateText;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.contentMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.pagePadding,
            right: AppConstants.pagePadding,
            bottom: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dateText != null) ...[
                Text(
                  dateText!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  shadows: [
                    Shadow(
                      color: AppColors.shadow.withValues(alpha: 0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
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
