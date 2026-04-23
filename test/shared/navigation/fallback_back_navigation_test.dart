import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:galaxydox/shared/navigation/fallback_back_navigation.dart';

void main() {
  testWidgets('system back falls back to the named route when stack is empty', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
        GoRoute(
          path: '/detail',
          name: 'detail',
          builder: (context, state) => const FallbackBackNavigationScope(
            fallbackRouteName: 'home',
            child: Scaffold(body: Center(child: Text('Detail'))),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Detail'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Detail'), findsNothing);
  });

  testWidgets(
    'system back pops the current route when a previous page exists',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => context.pushNamed('detail'),
                  child: const Text('Open detail'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/detail',
            name: 'detail',
            builder: (context, state) => const FallbackBackNavigationScope(
              fallbackRouteName: 'home',
              child: Scaffold(body: Center(child: Text('Detail'))),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Open detail'), findsOneWidget);
      expect(find.text('Detail'), findsNothing);
    },
  );
}
