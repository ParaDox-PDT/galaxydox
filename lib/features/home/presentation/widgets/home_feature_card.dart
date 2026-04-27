import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../providers/home_preview_provider.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({super.key, required this.feature});

  final HomeFeaturePreview feature;

  static final _shadowDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    boxShadow: const [
      BoxShadow(
        color: Color(0x3D020611),
        blurRadius: 34,
        offset: Offset(0, 22),
      ),
    ],
  );

  static final _borderRadius = BorderRadius.circular(30);

  static const _kickerDecoration = BoxDecoration(
    color: Color(0x38000000),
    borderRadius: BorderRadius.all(Radius.circular(999)),
    border: Border.fromBorderSide(BorderSide(color: Color(0x14FFFFFF))),
  );

  static const _descriptionColor = Color(0xC2F6F8FD);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final accentGlow = BoxDecoration(
      gradient: AppGradients.ambientGlow(
        alignment: const Alignment(0.85, -0.85),
        color: feature.accentColor,
        radius: 1,
        alpha: 0.22,
      ),
    );
    final surfaceGradient = AppGradients.storySurface(accent: feature.accentColor);
    final accentBorder = Border.all(color: feature.accentColor.withValues(alpha: 0.18));
    final iconDec = BoxDecoration(
      color: feature.accentColor.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: feature.accentColor.withValues(alpha: 0.26)),
    );
    final ctaOverlayDec = BoxDecoration(
      color: feature.accentColor.withValues(alpha: 0.14),
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      border: Border.all(color: feature.accentColor.withValues(alpha: 0.22)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 420;
        final isMedium = width < 720;
        final imageAspectRatio = isCompact ? 1.6 : isMedium ? 1.9 : 2.2;

        return Container(
          decoration: _shadowDecoration,
          child: ClipRRect(
            borderRadius: _borderRadius,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.pushNamed(feature.routeName),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: surfaceGradient,
                    border: accentBorder,
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
                              child: DecoratedBox(decoration: accentGlow),
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
                                decoration: iconDec,
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
                                constraints: const BoxConstraints(maxWidth: 180),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: _kickerDecoration,
                                  child: Text(
                                    feature.kicker.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelMedium?.copyWith(
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
                                    decoration: ctaOverlayDec,
                                    child: Text(
                                      feature.ctaLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelLarge?.copyWith(
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
                                color: _descriptionColor,
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
