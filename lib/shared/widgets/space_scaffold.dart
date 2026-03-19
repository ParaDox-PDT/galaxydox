import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';
import 'ambient_space_background.dart';

class SpaceScaffold extends StatelessWidget {
  const SpaceScaffold({
    super.key,
    required this.body,
    this.topSafeArea = true,
    this.bottomSafeArea = false,
  });

  final Widget body;
  final bool topSafeArea;
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientSpaceBackground(),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.screenVeil),
          ),
          SafeArea(top: topSafeArea, bottom: bottomSafeArea, child: body),
        ],
      ),
    );
  }
}
