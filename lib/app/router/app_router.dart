import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/apod/presentation/pages/apod_page.dart';
import '../../features/demo/presentation/pages/aurora_demo_page.dart';
import '../../features/epic_earth/presentation/pages/epic_earth_gallery_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mars_rover/presentation/pages/mars_rover_page.dart';
import '../../features/nasa_search/presentation/pages/nasa_search_page.dart';
import '../../features/neo/presentation/pages/neo_page.dart';
import '../../features/planets_3d/presentation/pages/planet_detail_page.dart';
import '../../features/planets_3d/presentation/pages/planets_3d_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/bookmarks/presentation/pages/bookmarks_page.dart';
import '../../shared/widgets/coming_soon_page.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splashPath,
    routes: _routes,
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

final List<RouteBase> _routes = [
  _appRoute(
    path: AppRoutes.splashPath,
    name: AppRoutes.splashName,
    child: const SplashPage(),
  ),
  _appRoute(
    path: AppRoutes.homePath,
    name: AppRoutes.homeName,
    child: const HomePage(),
  ),
  _appRoute(
    path: AppRoutes.apodPath,
    name: AppRoutes.apodName,
    child: const ApodPage(),
  ),
  _appRoute(
    path: AppRoutes.marsRoverPath,
    name: AppRoutes.marsRoverName,
    child: const MarsRoverPage(),
  ),
  _appRoute(
    path: AppRoutes.epicEarthPath,
    name: AppRoutes.epicEarthName,
    child: const EpicEarthGalleryPage(),
  ),
  _appRoute(
    path: AppRoutes.neoPath,
    name: AppRoutes.neoName,
    child: const NeoPage(),
  ),
  _appRoute(
    path: AppRoutes.searchPath,
    name: AppRoutes.searchName,
    child: const NasaSearchPage(),
  ),
  _appRoute(
    path: AppRoutes.bookmarksPath,
    name: AppRoutes.bookmarksName,
    child: const BookmarksPage(),
  ),
  _appRoute(
    path: AppRoutes.auroraDemoPath,
    name: AppRoutes.auroraDemoName,
    child: const AuroraDemoPage(),
  ),
  _appRoute(
    path: AppRoutes.settingsPath,
    name: AppRoutes.settingsName,
    child: const SettingsPage(),
  ),
  _appRoute(
    path: AppRoutes.planets3dPath,
    name: AppRoutes.planets3dName,
    child: const Planets3DPage(),
  ),
  GoRoute(
    path: AppRoutes.planetDetailPath,
    name: AppRoutes.planetDetailName,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return _buildPage(
        state: state,
        child: PlanetDetailPage(planetId: id),
      );
    },
  ),
];

GoRoute _appRoute({
  required String path,
  required String name,
  required Widget child,
}) {
  return GoRoute(
    path: path,
    name: name,
    pageBuilder: (context, state) => _buildPage(state: state, child: child),
  );
}

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppConstants.motionSlow,
    reverseTransitionDuration: AppConstants.motionMedium,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      final offset = Tween<Offset>(
        begin: const Offset(0, 0.028),
        end: Offset.zero,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: offset,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.995, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}
