import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../providers/home_preview_provider.dart';

class HeroFeatureCard extends StatelessWidget {
  const HeroFeatureCard({super.key, required this.hero});

  final HomeHeroContent hero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 420;
        final isMedium = width < 700;
        final showCapsule = constraints.maxWidth >= 960;
        final contentWidth = showCapsule ? constraints.maxWidth - 340 : null;
        final cardHeight = showCapsule
            ? AppConstants.heroHeight
            : isCompact
            ? 780.0
            : isMedium
            ? 660.0
            : 600.0;
        final visibleMetrics = showCapsule
            ? hero.metrics
            : isCompact
            ? hero.metrics.take(2).toList(growable: false)
            : hero.metrics;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.34),
                blurRadius: 44,
                offset: const Offset(0, 28),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PremiumNetworkImage(imageUrl: hero.imageUrl, fit: BoxFit.cover),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.ambientGlow(
                        alignment: const Alignment(0.8, -0.8),
                        color: AppColors.primaryStrong,
                        radius: 1.05,
                        alpha: 0.28,
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.heroOverlay,
                    ),
                  ),
                ),
                if (showCapsule)
                  Positioned(
                    top: 28,
                    right: 28,
                    bottom: 28,
                    child: SizedBox(
                      width: 280,
                      child: _CapsulePanel(hero: hero),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(isCompact ? 22 : 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _TopBadge(
                            label: hero.eyebrow,
                            color: AppColors.primary,
                          ),
                          const _TopBadge(
                            label: 'NASA Open APIs',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentWidth ?? 760,
                        ),
                        child: Text(
                          hero.title,
                          maxLines: isCompact ? 5 : 6,
                          overflow: TextOverflow.ellipsis,
                          style: isCompact
                              ? theme.textTheme.headlineLarge
                              : isMedium
                              ? theme.textTheme.displaySmall
                              : theme.textTheme.displayMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentWidth ?? 720,
                        ),
                        child: Text(
                          hero.description,
                          maxLines: isCompact ? 4 : 5,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.86,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final metric in visibleMetrics)
                            _MetricPill(metric: metric),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                context.pushNamed(hero.primaryRouteName),
                            icon: const Icon(Icons.open_in_full_rounded),
                            label: Text(hero.primaryLabel),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.pushNamed(hero.secondaryRouteName),
                            icon: const Icon(Icons.travel_explore_rounded),
                            label: Text(hero.secondaryLabel),
                          ),
                        ],
                      ),
                      if (!showCapsule) ...[
                        const SizedBox(height: 18),
                        _CapsulePanel(hero: hero, compact: true),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CapsulePanel extends StatelessWidget {
  const _CapsulePanel({required this.hero, this.compact = false});

  final HomeHeroContent hero;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    if (compact && isCompact) {
      return FrostedPanel(
        radius: 28,
        padding: const EdgeInsets.all(16),
        backgroundColor: AppColors.surface.withValues(alpha: 0.36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hero.capsuleTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hero.capsuleDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Designed for discovery first.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final visibleTags = compact && isCompact
        ? hero.tags.take(2).toList(growable: false)
        : hero.tags;
    final visibleMetrics = compact && isCompact
        ? hero.metrics.take(1).toList(growable: false)
        : compact
        ? hero.metrics.take(2).toList(growable: false)
        : hero.metrics;

    return FrostedPanel(
      radius: 28,
      padding: EdgeInsets.all(compact ? 20 : 22),
      backgroundColor: AppColors.surface.withValues(alpha: 0.36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hero.capsuleTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(hero.capsuleDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in visibleTags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  child: Text(tag, style: theme.textTheme.labelMedium),
                ),
            ],
          ),
          if (!compact) ...[
            const Spacer(),
            const Divider(height: 32),
          ] else
            const SizedBox(height: 16),
          if (compact)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final metric in visibleMetrics)
                  _MiniMetric(metric: metric),
              ],
            )
          else
            Column(
              children: [
                for (final metric in hero.metrics) ...[
                  _MetricRow(metric: metric),
                  if (metric != hero.metrics.last) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          letterSpacing: 1.2,
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final FeatureMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(metric.label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text(metric.value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.metric});

  final FeatureMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(metric.value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
