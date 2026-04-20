import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/wallpaper_entity.dart';
import '../providers/wallpapers_provider.dart';

class WallpapersPage extends ConsumerWidget {
  const WallpapersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpapersAsync = ref.watch(wallpapersProvider);

    return SpaceScaffold(
      body: PremiumRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wallpapersProvider);
          await ref.read(wallpapersProvider.future);
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
                      16,
                    ),
                    child: PageHeader(
                      title: 'Wallpapers',
                      subtitle:
                          'Curated space imagery from our collection. Download to your device or share with friends.',
                      actions: [
                        FilledButton.icon(
                          onPressed: () => ref.invalidate(wallpapersProvider),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                ),
              ),
            ),
            wallpapersAsync.when(
              loading: () => const _WallpapersLoadingGrid(),
              error: (error, _) => SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.contentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePadding,
                      ),
                      child: StatePanel(
                        title: 'Unable to load wallpapers',
                        message: _resolveErrorMessage(error),
                        icon: Icons.cloud_off_rounded,
                        accent: AppColors.warning,
                        actions: [
                          StatePanelAction(
                            label: 'Try again',
                            icon: Icons.refresh_rounded,
                            onPressed: () => ref.invalidate(wallpapersProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              data: (wallpapers) {
                if (wallpapers.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppConstants.contentMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.pagePadding,
                          ),
                          child: StatePanel(
                            title: 'No wallpapers yet',
                            message:
                                'The wallpapers collection is empty right now. Check back soon.',
                            icon: Icons.image_not_supported_rounded,
                            accent: AppColors.secondary,
                            actions: [
                              StatePanelAction(
                                label: 'Refresh',
                                icon: Icons.refresh_rounded,
                                onPressed: () =>
                                    ref.invalidate(wallpapersProvider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return _WallpaperGrid(wallpapers: wallpapers);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  String _resolveErrorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}

class _WallpaperGrid extends StatelessWidget {
  const _WallpaperGrid({required this.wallpapers});

  final List<WallpaperEntity> wallpapers;

  @override
  Widget build(BuildContext context) {
    return _WallpapersGridSliver(
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        return _WallpaperGridItem(wallpaper: wallpapers[index])
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 60 * index),
              duration: AppConstants.motionMedium,
            )
            .slideY(begin: 0.06, end: 0);
      },
    );
  }
}

class _WallpapersGridSliver extends StatelessWidget {
  const _WallpapersGridSliver({
    required this.itemCount,
    required this.itemBuilder,
    this.gridDelegate,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final SliverGridDelegate? gridDelegate;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = _gridHorizontalPadding(
          constraints.crossAxisExtent,
        );
        final contentWidth = math
            .max(0, constraints.crossAxisExtent - (horizontalPadding * 2))
            .toDouble();

        final resolvedGridDelegate =
            gridDelegate ??
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCountForWidth(contentWidth),
              mainAxisSpacing: AppConstants.cardGap * 0.6,
              crossAxisSpacing: AppConstants.cardGap * 0.6,
              childAspectRatio: 0.72,
            );

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
            gridDelegate: resolvedGridDelegate,
          ),
        );
      },
    );
  }
}

class _WallpaperGridItem extends StatelessWidget {
  const _WallpaperGridItem({required this.wallpaper});

  final WallpaperEntity wallpaper;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.wallpaperDetailName,
          pathParameters: {'id': wallpaper.id},
          extra: wallpaper,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PremiumNetworkImage(
              imageUrl: wallpaper.imageUrl,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.shadow.withValues(alpha: 0.55),
                      AppColors.shadow.withValues(alpha: 0.88),
                    ],
                    stops: const [0, 0.45, 0.75, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                wallpaper.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpapersLoadingGrid extends StatelessWidget {
  const _WallpapersLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return _WallpapersGridSliver(
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.cardGap * 0.6,
        crossAxisSpacing: AppConstants.cardGap * 0.6,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              child: const ColoredBox(color: AppColors.surfaceElevated),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(
              duration: const Duration(milliseconds: 1200),
              color: AppColors.surfaceStrong,
            );
      },
    );
  }
}

double _gridHorizontalPadding(double viewportWidth) {
  return math.max(
    AppConstants.pagePadding,
    (viewportWidth - AppConstants.contentMaxWidth) / 2,
  );
}

int _crossAxisCountForWidth(double contentWidth) {
  if (contentWidth >= 1080) return 4;
  if (contentWidth >= 720) return 3;
  return 2;
}
