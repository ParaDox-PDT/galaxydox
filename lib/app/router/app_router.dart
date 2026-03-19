import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/apod/presentation/pages/apod_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mars_rover/presentation/pages/mars_rover_page.dart';
import '../../features/nasa_search/presentation/pages/nasa_search_page.dart';
import '../../features/neo/presentation/pages/neo_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/widgets/coming_soon_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const HomePage()),
      ),
      GoRoute(
        path: AppRoutes.apodPath,
        name: AppRoutes.apodName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const ApodPage()),
      ),
      GoRoute(
        path: AppRoutes.marsRoverPath,
        name: AppRoutes.marsRoverName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const MarsRoverPage()),
      ),
      GoRoute(
        path: AppRoutes.neoPath,
        name: AppRoutes.neoName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const NeoPage()),
      ),
      GoRoute(
        path: AppRoutes.searchPath,
        name: AppRoutes.searchName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const NasaSearchPage()),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settingsName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const SettingsPage()),
      ),
    ],
    errorPageBuilder: (context, state) => _buildPage(
      state: state,
      child: const ComingSoonPage(
        title: 'Lost in orbit',
        description:
            'The route you requested is not part of the current flight plan.',
        highlights: [
          'Return to mission control',
          'Continue exploring NASA content',
          'Keep the navigation tree tidy',
        ],
        ctaLabel: 'Back to Home',
      ),
    ),
  );
});

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.035),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
