import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'loading_skeleton.dart';

class PremiumNetworkImage extends StatelessWidget {
  const PremiumNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image = kIsWeb ? _buildWebImage() : _buildCachedImage();

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildWebImage() {
    return Image.network(
      imageUrl,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return _buildPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildError(),
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
    );
  }

  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      fadeInDuration: AppConstants.motionMedium,
      fadeOutDuration: AppConstants.motionFast,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildError(),
    );
  }

  Widget _buildPlaceholder() {
    return SkeletonScope(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
      ),
    );
  }

  Widget _buildError() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: Icon(
            Icons.photo_outlined,
            color: AppColors.textMuted,
            size: 32,
          ),
        ),
      ),
    );
  }
}
