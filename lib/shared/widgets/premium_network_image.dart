import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

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
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.surfaceStrong,
        highlightColor: AppColors.surfaceSoft,
        child: Container(
          width: width,
          height: height,
          color: AppColors.surfaceStrong,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceStrong,
        alignment: Alignment.center,
        child: const Icon(
          Icons.photo_outlined,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
