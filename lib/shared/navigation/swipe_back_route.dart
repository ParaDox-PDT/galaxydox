import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class SwipeBackPageRoute<T> extends CupertinoPageRoute<T> {
  SwipeBackPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog = false,
    super.maintainState = true,
  });
}

CupertinoPage<T> buildSwipeBackPage<T>({
  required GoRouterState state,
  required Widget child,
  bool fullscreenDialog = false,
}) {
  return CupertinoPage<T>(
    key: state.pageKey,
    name: state.name ?? state.matchedLocation,
    arguments: state.extra,
    fullscreenDialog: fullscreenDialog,
    child: child,
  );
}
