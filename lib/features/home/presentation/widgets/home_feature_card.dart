import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../providers/home_preview_provider.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({super.key, required this.feature});

  final HomeFeaturePreview feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 420;
        final cardHeight = isCompact ? 400.0 : AppConstants.featureCardHeight;
        final visibleMetrics = isCompact
            ? feature.metrics.take(1)
            : feature.metrics;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.24),
                blurRadius: 34,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.pushNamed(feature.routeName),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.storySurface(
                      accent: feature.accentColor,
                    ),
                    border: Border.all(
                      color: feature.accentColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: isCompact ? 5 : 6,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PremiumNetworkImage(
                              imageUrl: feature.imageUrl,
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.ambientGlow(
                                    alignment: const Alignment(0.85, -0.85),
                                    color: feature.accentColor,
                                    radius: 1,
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                            ),
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.imageCardOverlay,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: feature.accentColor.withValues(
                                            alpha: 0.18,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: feature.accentColor
                                                .withValues(alpha: 0.26),
                                          ),
                                        ),
                                        child: Icon(
                                          feature.icon,
                                          color: feature.accentColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.22,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.08,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            feature.kicker.toUpperCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: AppColors.textPrimary,
                                                  letterSpacing: 1.3,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: feature.accentColor.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: feature.accentColor.withValues(
                                          alpha: 0.22,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      feature.ctaLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: feature.accentColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: isCompact ? 6 : 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature.title,
                                maxLines: isCompact ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: isCompact
                                    ? theme.textTheme.titleLarge
                                    : theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                feature.description,
                                maxLines: isCompact ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary.withValues(
                                    alpha: 0.76,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final metric in visibleMetrics)
                                    _CompactMetric(
                                      accentColor: feature.accentColor,
                                      metric: metric,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      feature.ctaLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: feature.accentColor,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_outward_rounded,
                                    color: feature.accentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.accentColor, required this.metric});

  final Color accentColor;
  final FeatureMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.58),
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
