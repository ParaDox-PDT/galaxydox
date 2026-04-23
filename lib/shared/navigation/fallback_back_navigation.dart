import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void popOrGoNamed(BuildContext context, {required String fallbackRouteName}) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }

  context.goNamed(fallbackRouteName);
}

class FallbackBackNavigationScope extends StatelessWidget {
  const FallbackBackNavigationScope({
    required this.fallbackRouteName,
    required this.child,
    super.key,
  });

  final String fallbackRouteName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return PopScope<void>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        popOrGoNamed(context, fallbackRouteName: fallbackRouteName);
      },
      child: child,
    );
  }
}
