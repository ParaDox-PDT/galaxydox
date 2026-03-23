import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

final homePreviewProvider = Provider<HomePreviewData>((ref) {
  return const HomePreviewData(
    hero: HomeHeroContent(
      eyebrow: 'Featured orbit',
      title:
          'A premium NASA field guide for tonight\'s most compelling stories.',
      description:
          'Move from the daily APOD narrative to rover imagery, asteroid intelligence, and NASA\'s media vault inside one calm cinematic mobile experience.',
      imageUrl: AppConstants.homeHeroImage,
      primaryLabel: 'Enter APOD',
      primaryRouteName: AppRoutes.apodName,
      secondaryLabel: 'Search archive',
      secondaryRouteName: AppRoutes.searchName,
      capsuleTitle: 'Mission capsule',
      capsuleDescription:
          'Designed for discovery first, with clean architecture and live NASA data lanes ready to plug in.',
      tags: ['NASA Open APIs', 'Editorial discovery', 'Dark cinematic UI'],
      metrics: [
        FeatureMetric(label: 'Daily story', value: 'APOD'),
        FeatureMetric(label: 'Surface gallery', value: 'Mars rovers'),
        FeatureMetric(label: 'Deep scan', value: 'Near-Earth objects'),
      ],
    ),
    sections: [
      HomeFeaturePreview(
        routeName: AppRoutes.apodName,
        kicker: 'Daily editorial',
        title: 'Astronomy Picture of the Day',
        description:
            'Today\'s image or video, expanded into a full-screen story with elegant long-form context and HD-ready presentation.',
        imageUrl: AppConstants.apodPreviewImage,
        accentColor: AppColors.primary,
        icon: Icons.auto_awesome_rounded,
        ctaLabel: 'Open today\'s story',
        metrics: [
          FeatureMetric(label: 'Format', value: 'Image or video'),
          FeatureMetric(label: 'Experience', value: 'HD detail'),
        ],
      ),
      HomeFeaturePreview(
        routeName: AppRoutes.marsRoverName,
        kicker: 'Surface archive',
        title: 'Mars Rover Gallery',
        description:
            'Browse rover photography with date filters, camera metadata, and an image-first layout tuned for long scrolling sessions.',
        imageUrl: AppConstants.marsPreviewImage,
        accentColor: AppColors.secondary,
        icon: Icons.rocket_launch_rounded,
        ctaLabel: 'Browse rover frames',
        metrics: [
          FeatureMetric(label: 'Filters', value: 'Rover and date'),
          FeatureMetric(label: 'Metadata', value: 'Camera and status'),
        ],
      ),
      HomeFeaturePreview(
        routeName: AppRoutes.neoName,
        kicker: 'Risk intelligence',
        title: 'Near-Earth Object Watch',
        description:
            'Track asteroid flybys with hazard indicators, miss distance, size, and velocity presented with calm readable density.',
        imageUrl: AppConstants.neoPreviewImage,
        accentColor: AppColors.warning,
        icon: Icons.track_changes_rounded,
        ctaLabel: 'Track asteroid flow',
        metrics: [
          FeatureMetric(label: 'Signals', value: 'Hazard status'),
          FeatureMetric(label: 'Telemetry', value: 'Velocity and size'),
        ],
      ),
      HomeFeaturePreview(
        routeName: AppRoutes.searchName,
        kicker: 'Media vault',
        title: 'Image and Video Search',
        description:
            'Search NASA imagery and video collections with a discovery-first interface built for browsing, not just retrieval.',
        imageUrl: AppConstants.searchPreviewImage,
        accentColor: AppColors.tertiary,
        icon: Icons.grid_view_rounded,
        ctaLabel: 'Search the archive',
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
    required this.capsuleTitle,
    required this.capsuleDescription,
    required this.tags,
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
  final String capsuleTitle;
  final String capsuleDescription;
  final List<String> tags;
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
