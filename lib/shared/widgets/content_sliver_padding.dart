import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class ContentSliverPadding extends StatelessWidget {
  const ContentSliverPadding({
    super.key,
    required this.sliver,
    this.top = 0,
    this.bottom = 0,
    this.horizontal = AppConstants.pagePadding,
  });

  final Widget sliver;
  final double top;
  final double bottom;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final extraHorizontalInset =
            ((constraints.crossAxisExtent - AppConstants.contentMaxWidth) / 2)
                .clamp(0.0, double.infinity);

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontal + extraHorizontalInset,
            top,
            horizontal + extraHorizontalInset,
            bottom,
          ),
          sliver: sliver,
        );
      },
    );
  }
}
