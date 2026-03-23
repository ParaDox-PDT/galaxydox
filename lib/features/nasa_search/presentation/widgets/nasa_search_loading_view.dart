import 'package:flutter/material.dart';

import '../../../../shared/widgets/loading_skeleton.dart';
import '../providers/nasa_search_controller.dart';

class NasaSearchLoadingView extends StatelessWidget {
  const NasaSearchLoadingView({super.key, required this.viewMode});

  final NasaSearchViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return SkeletonScope(
      child: viewMode == NasaSearchViewMode.grid
          ? LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1100
                    ? 3
                    : constraints.maxWidth >= 720
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: crossAxisCount == 1 ? 1.05 : 0.78,
                  ),
                  itemBuilder: (context, index) =>
                      const SkeletonBlock(height: double.infinity),
                );
              },
            )
          : Column(
              children: [
                for (var index = 0; index < 5; index++) ...[
                  const SkeletonBlock(height: 164),
                  if (index != 4) const SizedBox(height: 16),
                ],
              ],
            ),
    );
  }
}
