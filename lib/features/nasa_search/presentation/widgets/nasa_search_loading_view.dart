import 'package:flutter/material.dart';

import '../../../../shared/widgets/loading_skeleton.dart';

class NasaSearchLoadingView extends StatelessWidget {
  const NasaSearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: Column(
        children: [
          SkeletonBlock(height: 164),
          SizedBox(height: 16),
          SkeletonBlock(height: 164),
          SizedBox(height: 16),
          SkeletonBlock(height: 164),
          SizedBox(height: 16),
          SkeletonBlock(height: 164),
          SizedBox(height: 16),
          SkeletonBlock(height: 164),
        ],
      ),
    );
  }
}
