import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

final homePreviewProvider = Provider<HomePreviewData>((ref) {
  return const HomePreviewData(
    hero: HomeHeroContent(
      eyebrow: 'Tonight\'s Briefing',
      title: 'Explore the cosmos through NASA\'s most cinematic archives.',
      description:
          'GalaxyDox brings together APOD storytelling, Mars rover imagery, asteroid intelligence, and NASA\'s vast media vault in a premium editorial experience.',
      imageUrl: AppConstants.homeHeroImage,
      primaryLabel: 'Open APOD',
      primaryRouteName: AppRoutes.apodName,
      secondaryLabel: 'Search Media',
      secondaryRouteName: AppRoutes.searchName,
      metrics: [
        FeatureMetric(label: 'Daily focus', value: 'APOD'),
        FeatureMetric(label: 'Rover archive', value: 'Mars surface'),
        FeatureMetric(label: 'Asteroid watch', value: 'NEO feed'),
      ],
    ),
    sections: [
      HomeFeaturePreview(
        routeName: AppRoutes.apodName,
        kicker: 'Daily editorial',
        title: 'Astronomy Picture of the Day',
        description:
            'Today\'s image or video, expanded into a rich story with HD viewing and elegant long-form reading.',
        imageUrl: AppConstants.apodPreviewImage,
        accentColor: AppColors.primary,
        icon: Icons.auto_awesome_rounded,
        ctaLabel: 'View today',
        metrics: [
          FeatureMetric(label: 'Content', value: 'Image or video'),
          FeatureMetric(label: 'Depth', value: 'Explanation'),
        ],
      ),
      HomeFeaturePreview(
        routeName: AppRoutes.marsRoverName,
        kicker: 'Surface imagery',
        title: 'Mars Rover Gallery',
        description:
            'Jump into rover archives with cinematic grids, date filters, and detailed camera metadata for every frame.',
        imageUrl: AppConstants.marsPreviewImage,
        accentColor: AppColors.secondary,
        icon: Icons.rocket_launch_rounded,
        ctaLabel: 'Browse rovers',
        metrics: [
          FeatureMetric(label: 'Filters', value: 'Rover and date'),
          FeatureMetric(label: 'Detail', value: 'Camera metadata'),
        ],
      ),
      HomeFeaturePreview(
        routeName: AppRoutes.neoName,
        kicker: 'Risk intelligence',
        title: 'Near-Earth Object Watch',
        description:
            'Scan asteroid flybys with hazard indicators, key dimensions, miss distance, and velocity in a calm readable layout.',
        imageUrl: AppConstants.neoPreviewImage,
        accentColor: AppColors.warning,
        icon: Icons.track_changes_rounded,
        ctaLabel: 'Track asteroids',
        metrics: [
          FeatureMetric(label: 'Signals', value: 'Hazard status'),
          FeatureMetric(label: 'Data', value: 'Velocity and size'),
        ],
      ),
      HomeFeaturePreview(
        routeName: AppRoutes.searchName,
        kicker: 'NASA media vault',
        title: 'Image and Video Search',
        description:
            'Search NASA imagery and video collections with a fast visual browser built for discovery, not just utility.',
        imageUrl: AppConstants.searchPreviewImage,
        accentColor: AppColors.tertiary,
        icon: Icons.grid_view_rounded,
        ctaLabel: 'Search archive',
        metrics: [
          FeatureMetric(label: 'Mode', value: 'Grid or list'),
          FeatureMetric(label: 'Scope', value: 'Image and video'),
        ],
      ),
    ],
  );
});

class HomePreviewData {
  const HomePreviewData({required this.hero, required this.sections});

  final HomeHeroContent hero;
  final List<HomeFeaturePreview> sections;
}

class HomeHeroContent {
  const HomeHeroContent({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.primaryLabel,
    required this.primaryRouteName,
    required this.secondaryLabel,
    required this.secondaryRouteName,
    required this.metrics,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String imageUrl;
  final String primaryLabel;
  final String primaryRouteName;
  final String secondaryLabel;
  final String secondaryRouteName;
  final List<FeatureMetric> metrics;
}

class HomeFeaturePreview {
  const HomeFeaturePreview({
    required this.routeName,
    required this.kicker,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.accentColor,
    required this.icon,
    required this.ctaLabel,
    required this.metrics,
  });

  final String routeName;
  final String kicker;
  final String title;
  final String description;
  final String imageUrl;
  final Color accentColor;
  final IconData icon;
  final String ctaLabel;
  final List<FeatureMetric> metrics;
}

class FeatureMetric {
  const FeatureMetric({required this.label, required this.value});

  final String label;
  final String value;
}
