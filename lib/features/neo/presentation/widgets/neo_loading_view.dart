import 'package:flutter/material.dart';

import '../../../../shared/widgets/loading_skeleton.dart';

class NeoLoadingView extends StatelessWidget {
  const NeoLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonScope(
      child: Column(
        children: [
          for (var index = 0; index < 4; index++) ...[
            const SkeletonBlock(height: 214),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
