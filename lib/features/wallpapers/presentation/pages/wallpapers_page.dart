import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
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

class WallpapersPage extends ConsumerStatefulWidget {
  const WallpapersPage({super.key});

  @override
  ConsumerState<WallpapersPage> createState() => _WallpapersPageState();
}

class _WallpapersPageState extends ConsumerState<WallpapersPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallpapersAsync = ref.watch(wallpapersProvider);

    return SpaceScaffold(
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: PremiumRefreshIndicator(
          onRefresh: () =>
              ref.read(wallpapersProvider.notifier).forceRefresh(),
          child: CustomScrollView(
            controller: _scrollController,
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
                            onPressed: () => ref
                                .read(wallpapersProvider.notifier)
                                .forceRefresh(),
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
                              onPressed: () => ref
                                  .read(wallpapersProvider.notifier)
                                  .forceRefresh(),
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
                                  onPressed: () => ref
                                      .read(wallpapersProvider.notifier)
                                      .forceRefresh(),
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
        final item = _WallpaperGridItem(wallpaper: wallpapers[index]);
        // Only stagger-animate the first 12 items to avoid creating hundreds
        // of simultaneous animation controllers on long lists.
        if (index >= 12) return item;
        return item
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
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = _gridHorizontalPadding(
          constraints.crossAxisExtent,
        );
        final contentWidth = math.max(
          0.0,
          constraints.crossAxisExtent - (horizontalPadding * 2),
        );
        final gridSpec = _wallpaperGridSpecFor(contentWidth);

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSpec.crossAxisCount,
              mainAxisSpacing: gridSpec.spacing,
              crossAxisSpacing: gridSpec.spacing,
              childAspectRatio: gridSpec.childAspectRatio,
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 210;
        final theme = Theme.of(context);
        final titleStyle =
            (isCompact
                    ? theme.textTheme.labelLarge
                    : theme.textTheme.titleMedium)
                ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                );
        final bodyStyle = theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          height: 1.35,
        );

        return Semantics(
          button: true,
          label: wallpaper.title,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              onTap: () {
                context.pushNamed(
                  AppRoutes.wallpaperDetailName,
                  pathParameters: {'id': wallpaper.id},
                  extra: wallpaper,
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  border: Border.all(color: AppColors.outlineSoft),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'wallpaper-hero-${wallpaper.id}',
                        flightShuttleBuilder: (_, _, _, _, _) =>
                            ColoredBox(
                              color: Colors.black,
                              child: CachedNetworkImage(
                                imageUrl: wallpaper.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                        child: PremiumNetworkImage(
                          imageUrl: wallpaper.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.backgroundDeep.withValues(
                                  alpha: 0.08,
                                ),
                                Colors.transparent,
                                AppColors.shadow.withValues(alpha: 0.58),
                                AppColors.backgroundDeep.withValues(
                                  alpha: 0.96,
                                ),
                              ],
                              stops: const [0, 0.38, 0.72, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDeep.withValues(
                              alpha: 0.56,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.outlineSoft),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.open_in_full_rounded,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              wallpaper.title,
                              maxLines: isCompact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                            if (!isCompact &&
                                wallpaper.description.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                wallpaper.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: bodyStyle,
                              ),
                            ],
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

class _WallpaperGridSpec {
  const _WallpaperGridSpec({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.spacing,
  });

  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
}

_WallpaperGridSpec _wallpaperGridSpecFor(double contentWidth) {
  if (contentWidth < 420) {
    return const _WallpaperGridSpec(
      crossAxisCount: 1,
      childAspectRatio: 1.12,
      spacing: 14,
    );
  }

  if (contentWidth < 760) {
    return const _WallpaperGridSpec(
      crossAxisCount: 2,
      childAspectRatio: 0.82,
      spacing: 14,
    );
  }

  if (contentWidth < 1120) {
    return const _WallpaperGridSpec(
      crossAxisCount: 3,
      childAspectRatio: 0.78,
      spacing: 16,
    );
  }

  return const _WallpaperGridSpec(
    crossAxisCount: 4,
    childAspectRatio: 0.76,
    spacing: 18,
  );
}

class _WallpapersLoadingGrid extends StatelessWidget {
  const _WallpapersLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return _WallpapersGridSliver(
      itemCount: 6,
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
