import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/planet_entity.dart';
import '../providers/planets_providers.dart';

const _fallbackPlanetThumbnailAsset = 'assets/images/planets.png';

class Planets3DPage extends ConsumerWidget {
  const Planets3DPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planetsAsync = ref.watch(planetsProvider);

    return SpaceScaffold(
      body: PremiumRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(planetsProvider);
          await ref.read(planetsProvider.future);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pagePadding,
                      12,
                      AppConstants.pagePadding,
                      42,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: '3D Planets',
                          subtitle:
                              'Planets now load from Firebase, and each 3D model is cached on the device after the first download.',
                          actions: [
                            FilledButton.icon(
                              onPressed: () {
                                ref.invalidate(planetsProvider);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 28),
                        planetsAsync.when(
                          loading: () => const _PlanetsLoadingView(),
                          error: (error, stackTrace) => StatePanel(
                            title: 'Unable to load planets',
                            message: _resolveAsyncErrorMessage(error),
                            icon: Icons.cloud_off_rounded,
                            accent: AppColors.warning,
                            actions: [
                              StatePanelAction(
                                label: 'Try again',
                                icon: Icons.refresh_rounded,
                                onPressed: () {
                                  ref.invalidate(planetsProvider);
                                },
                              ),
                            ],
                          ),
                          data: (planets) {
                            if (planets.isEmpty) {
                              return StatePanel(
                                title: 'No planets found',
                                message:
                                    'The Firebase `planets` collection is empty right now. Add documents there and they will appear here automatically.',
                                icon: Icons.public_off_rounded,
                                accent: AppColors.secondary,
                                actions: [
                                  StatePanelAction(
                                    label: 'Refresh',
                                    icon: Icons.refresh_rounded,
                                    onPressed: () {
                                      ref.invalidate(planetsProvider);
                                    },
                                  ),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < planets.length; i++)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: i < planets.length - 1
                                          ? AppConstants.cardGap
                                          : 0,
                                    ),
                                    child: _PlanetCard(planet: planets[i])
                                        .animate()
                                        .fadeIn(
                                          delay: Duration(
                                            milliseconds: 120 + i * 90,
                                          ),
                                          duration: 480.ms,
                                        )
                                        .slideY(begin: 0.06, end: 0),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _resolveAsyncErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Planets collection could not be loaded right now.';
  }
}

class _PlanetCard extends StatelessWidget {
  const _PlanetCard({required this.planet});

  final PlanetEntity planet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final cardHeight = compact ? 196.0 : 208.0;
        final imagePaneWidth = compact ? 148.0 : 180.0;
        final imageSize = compact ? 124.0 : 150.0;
        final contentPadding = compact
            ? const EdgeInsets.fromLTRB(14, 16, 16, 16)
            : const EdgeInsets.fromLTRB(16, 20, 20, 20);
        final titleStyle = compact
            ? theme.textTheme.titleLarge
            : theme.textTheme.headlineSmall;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: planet.accentColor.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.pushNamed(
                  AppRoutes.planetDetailName,
                  pathParameters: {'id': planet.id},
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.storySurface(
                      accent: planet.accentColor,
                    ),
                    border: Border.all(
                      color: planet.accentColor.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: imagePaneWidth,
                        child: Stack(
                          children: [
                            Center(
                              child: Hero(
                                tag: 'planet_thumb_${planet.id}',
                                child: Container(
                                  width: imageSize,
                                  height: imageSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      compact ? 24 : 28,
                                    ),
                                    border: Border.all(
                                      color: planet.accentColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: planet.accentColor.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      compact ? 24 : 28,
                                    ),
                                    child: _PlanetThumbnail(
                                      planet: planet,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.center,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.surfaceElevated.withValues(
                                        alpha: 0.9,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: contentPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CardPill(
                                label: 'INTERACTIVE 3D',
                                accentColor: planet.accentColor,
                              ),
                              SizedBox(height: compact ? 10 : 14),
                              Text(
                                planet.title,
                                style: titleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                planet.subtitle.isEmpty
                                    ? 'Interactive 3D model'
                                    : planet.subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: compact ? 8 : 12),
                              Expanded(
                                child: Text(
                                  planet.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.45,
                                  ),
                                  maxLines: compact ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      compact
                                          ? 'Open in 3D'
                                          : 'Open and cache 3D model',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: planet.accentColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_outward_rounded,
                                    color: planet.accentColor,
                                    size: 18,
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

class _CardPill extends StatelessWidget {
  const _CardPill({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accentColor,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _PlanetThumbnail extends StatelessWidget {
  const _PlanetThumbnail({required this.planet, this.fit = BoxFit.cover});

  final PlanetEntity planet;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (planet.thumbnailUrl.isNotEmpty) {
      return PremiumNetworkImage(imageUrl: planet.thumbnailUrl, fit: fit);
    }

    return Image.asset(
      _fallbackPlanetThumbnailAsset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          _ThumbnailFallback(accentColor: planet.accentColor),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accentColor.withValues(alpha: 0.1),
      child: Icon(Icons.public_rounded, color: accentColor, size: 48),
    );
  }
}

class _PlanetsLoadingView extends StatelessWidget {
  const _PlanetsLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 2.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparing the planets for you...',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
