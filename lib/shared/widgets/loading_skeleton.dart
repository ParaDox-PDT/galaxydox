import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class SkeletonScope extends StatelessWidget {
  const SkeletonScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceStrong,
      highlightColor: AppColors.surfaceSoft,
      child: child,
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = AppConstants.radiusLarge,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonLines extends StatelessWidget {
  const SkeletonLines({
    super.key,
    this.lines = 4,
    this.lineHeight = 14,
    this.gap = 10,
  });

  final int lines;
  final double lineHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < lines; index++) ...[
          SkeletonBlock(
            height: lineHeight,
            width: index == lines - 1 ? 220 : double.infinity,
            radius: 8,
          ),
          if (index != lines - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}
