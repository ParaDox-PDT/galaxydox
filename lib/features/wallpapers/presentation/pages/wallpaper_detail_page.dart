import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
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
                style: TextStyle(color: AppColors.textPrimary),
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

    return SpaceScaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 460,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: _BackButton(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PremiumNetworkImage(
                    imageUrl: wallpaper.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.shadow.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.6),
                            AppColors.background,
                          ],
                          stops: const [0, 0.12, 0.6, 0.85, 1],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pagePadding,
                    4,
                    AppConstants.pagePadding,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wallpaper.createdAt != null) ...[
                        Text(
                          DateFormat.yMMMMd().format(wallpaper.createdAt!),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        wallpaper.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                      )
                          .animate()
                          .fadeIn(duration: AppConstants.motionMedium)
                          .slideY(begin: 0.05, end: 0),
                      if (wallpaper.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        FrostedPanel(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            wallpaper.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.65,
                                ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                              delay: 80.ms,
                              duration: AppConstants.motionMedium,
                            )
                            .slideY(begin: 0.05, end: 0),
                      ],
                      const SizedBox(height: 28),
                      _ActionRow(
                        isDownloading: _isDownloading,
                        downloadProgress: _downloadProgress,
                        onDownload: _downloadWallpaper,
                        onShare: _shareWallpaper,
                      )
                          .animate()
                          .fadeIn(
                            delay: 140.ms,
                            duration: AppConstants.motionMedium,
                          )
                          .slideY(begin: 0.05, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        onTap: () => Navigator.of(context).maybePop(),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isDownloading,
    required this.downloadProgress,
    required this.onDownload,
    required this.onShare,
  });

  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isDownloading ? null : onDownload,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.backgroundDeep,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
            ),
            icon: isDownloading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      value: downloadProgress > 0 ? downloadProgress : null,
                      strokeWidth: 2,
                      color: AppColors.backgroundDeep,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              isDownloading
                  ? downloadProgress > 0
                      ? '${(downloadProgress * 100).toInt()}%'
                      : 'Downloading…'
                  : 'Download',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onShare,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.outline),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
          ),
          icon: const Icon(Icons.share_rounded, size: 20),
          label: const Text(
            'Share',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
