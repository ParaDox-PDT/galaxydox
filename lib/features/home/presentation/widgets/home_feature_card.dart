import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Container(
      height: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: feature.accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.goNamed(feature.routeName),
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
                        radius: 0.98,
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardOverlay,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
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
                                alpha: 0.16,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: feature.accentColor.withValues(
                                  alpha: 0.28,
                                ),
                              ),
                            ),
                            child: Icon(
                              feature.icon,
                              color: feature.accentColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.26),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: const Icon(Icons.north_east_rounded),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        feature.kicker.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: feature.accentColor,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(feature.title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Text(
                        feature.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.76),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final metric in feature.metrics)
                            _CompactMetric(
                              accentColor: feature.accentColor,
                              metric: metric,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.6),
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
