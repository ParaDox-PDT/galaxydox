import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';
import 'ambient_space_background.dart';

class SpaceScaffold extends StatelessWidget {
  const SpaceScaffold({
    super.key,
    required this.body,
    this.topSafeArea = true,
    this.bottomSafeArea = false,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final bool topSafeArea;
  final bool bottomSafeArea;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: AmbientSpaceBackground()),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.screenVeil),
          ),
          SafeArea(top: topSafeArea, bottom: bottomSafeArea, child: body),
        ],
      ),
    );
  }
}
