import 'package:flutter/material.dart';

import '../../../../shared/widgets/loading_skeleton.dart';

class MarsRoverLoadingView extends StatelessWidget {
  const MarsRoverLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1080
            ? 3
            : constraints.maxWidth >= 720
            ? 2
            : 1;

        return SkeletonScope(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: crossAxisCount == 1 ? 1.08 : 0.82,
            ),
            itemBuilder: (context, index) {
              return const SkeletonBlock(height: double.infinity, radius: 28);
            },
          ),
        );
      },
    );
  }
}
