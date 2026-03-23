import 'package:flutter/material.dart';

import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class ApodLoadingView extends StatelessWidget {
  const ApodLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBlock(height: 420, radius: 32),
          const SizedBox(height: 22),
          FrostedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBlock(height: 18, width: 130, radius: 8),
                const SizedBox(height: 16),
                const SkeletonBlock(
                  height: 34,
                  width: double.infinity,
                  radius: 10,
                ),
                const SizedBox(height: 10),
                const SkeletonBlock(height: 16, width: 220, radius: 8),
                const SizedBox(height: 20),
                const SkeletonLines(lines: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
