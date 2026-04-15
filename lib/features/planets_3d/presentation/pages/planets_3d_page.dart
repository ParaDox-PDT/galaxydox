import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../data/planets_catalog.dart';
import '../../domain/planet_entity.dart';

class Planets3DPage extends StatelessWidget {
  const Planets3DPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planets = PlanetsCatalog.planets;

    return SpaceScaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pagePadding,
                    8,
                    AppConstants.pagePadding,
                    42,
                  ),
                  child: Column(
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
                                delay: Duration(milliseconds: 120 + i * 100),
                                duration: 480.ms,
                              )
                              .slideY(begin: 0.06, end: 0),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('3D Planets'),
      centerTitle: false,
      pinned: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDeep.withValues(alpha: 0.92),
              AppColors.backgroundDeep.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanetCard extends StatelessWidget {
  const _PlanetCard({required this.planet});

  final PlanetEntity planet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
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
                gradient: AppGradients.storySurface(accent: planet.accentColor),
                border: Border.all(
                  color: planet.accentColor.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'planet_thumb_${planet.id}',
                          child: Image.asset(
                            planet.thumbnailAssetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: planet.accentColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.public_rounded,
                                color: planet.accentColor,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  AppColors.surfaceElevated
                                      .withValues(alpha: 0.92),
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
                      padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  planet.accentColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    planet.accentColor.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              'INTERACTIVE 3D',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: planet.accentColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            planet.title,
                            style: theme.textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            planet.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                'View in 3D',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: planet.accentColor,
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
  }
}
