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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 420;
        final isMedium = width < 720;
        final imageAspectRatio = isCompact
            ? 1.6
            : isMedium
            ? 1.9
            : 2.2;
        return Container(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: imageAspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (feature.assetImagePath != null)
                              Image.asset(
                                feature.assetImagePath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            else
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
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: feature.accentColor.withValues(
                                    alpha: 0.18,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: feature.accentColor.withValues(
                                      alpha: 0.26,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  feature.icon,
                                  color: feature.accentColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 180,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(999),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isCompact ? 16 : 18,
                          isCompact ? 14 : 16,
                          isCompact ? 16 : 18,
                          isCompact ? 16 : 18,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              maxLines: isCompact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: isCompact
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feature.description,
                              maxLines: isCompact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.76,
                                ),
                              ),
                            ),
                            // Temporarily hidden per current home screen layout request.
                            // const SizedBox(height: 18),
                            // _FeatureMetricSection(
                            //   accentColor: feature.accentColor,
                            //   metrics: visibleMetrics,
                            //   isCompact: isCompact,
                            // ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    feature.ctaLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: feature.accentColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  color: feature.accentColor,
                                  size: 16,
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
          ),
        );
      },
    );
  }
}

class _FeatureMetricSection extends StatelessWidget {
  const _FeatureMetricSection({
    required this.accentColor,
    required this.metrics,
    required this.isCompact,
  });

  final Color accentColor;
  final List<FeatureMetric> metrics;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isCompact || metrics.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            _CompactMetric(accentColor: accentColor, metric: metrics[index]),
            if (index != metrics.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          Expanded(
            child: _CompactMetric(
              accentColor: accentColor,
              metric: metrics[index],
            ),
          ),
          if (index != metrics.length - 1) const SizedBox(width: 10),
        ],
      ],
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
      width: double.infinity,
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
