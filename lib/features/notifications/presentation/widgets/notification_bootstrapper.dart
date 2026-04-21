import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../providers/notification_lifecycle_provider.dart';

class NotificationBootstrapper extends ConsumerStatefulWidget {
  const NotificationBootstrapper({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrapper> createState() =>
      _NotificationBootstrapperState();
}

class _NotificationBootstrapperState
    extends ConsumerState<NotificationBootstrapper> {
  bool _didInitialize = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(notificationLifecycleControllerProvider)
          .initialize(
            router: ref.read(appRouterProvider),
            navigatorKey: ref.read(rootNavigatorKeyProvider),
          );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
