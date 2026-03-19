import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../providers/home_preview_provider.dart';

class HeroFeatureCard extends StatelessWidget {
  const HeroFeatureCard({super.key, required this.hero});

  final HomeHeroContent hero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppConstants.heroHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 40,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PremiumNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.ambientGlow(
                    alignment: const Alignment(0.8, -0.8),
                    color: AppColors.primary,
                    radius: 1,
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.heroOverlay),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      hero.eyebrow.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      hero.title,
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      hero.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.84),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final metric in hero.metrics)
                        _MetricPill(metric: metric),
                    ],
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: compact ? constraints.maxWidth : null,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  context.goNamed(hero.primaryRouteName),
                              icon: const Icon(Icons.open_in_full_rounded),
                              label: Text(hero.primaryLabel),
                            ),
                          ),
                          SizedBox(
                            width: compact ? constraints.maxWidth : null,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.goNamed(hero.secondaryRouteName),
                              icon: const Icon(Icons.travel_explore_rounded),
                              label: Text(hero.secondaryLabel),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.metric});

  final FeatureMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(metric.value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
