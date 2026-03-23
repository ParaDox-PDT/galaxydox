import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PremiumRefreshIndicator extends StatelessWidget {
  const PremiumRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryStrong,
      backgroundColor: AppColors.surfaceStrong,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
