import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class EpicEarthLoadingView extends StatelessWidget {
  const EpicEarthLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 1080
              ? 4
              : constraints.maxWidth >= 760
              ? 3
              : constraints.maxWidth >= 520
              ? 2
              : 1;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: crossAxisCount * 2,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SkeletonBlock(
                      height: double.infinity,
                      radius: AppConstants.radiusLarge,
                    ),
                  ),
                  SizedBox(height: 14),
                  SkeletonBlock(height: 16, width: 180, radius: 8),
                  SizedBox(height: 10),
                  SkeletonBlock(height: 14, width: 120, radius: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
