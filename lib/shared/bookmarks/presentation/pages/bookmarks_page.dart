import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/frosted_panel.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/space_scaffold.dart';
import '../../../widgets/state_panel.dart';
import '../providers/bookmark_controller.dart';
import '../widgets/bookmark_content_card.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkControllerProvider);
    final controller = ref.read(bookmarkControllerProvider.notifier);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: CustomScrollView(
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
                        title: 'Bookmarks',
                        subtitle:
                            'Your saved NASA stories, media, rover frames, and asteroid snapshots.',
                        actions: [
                          OutlinedButton.icon(
                            onPressed: controller.retry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.stackGap),
                      if (state.isLoading) const _BookmarksLoadingView(),
                      if (state.hasError)
                        StatePanel(
                          title: 'Unable to open bookmarks',
                          message: state.error!.message,
                          icon: Icons.bookmarks_outlined,
                          accent: AppColors.warning,
                          actions: [
                            StatePanelAction(
                              label: 'Try again',
                              icon: Icons.refresh_rounded,
                              onPressed: controller.retry,
                            ),
                          ],
                        ),
                      if (state.isEmpty)
                        StatePanel(
                          title: 'No bookmarks yet',
                          message:
                              'Save an APOD story, rover photo, asteroid entry, or NASA media result and it will appear here for quick return visits.',
                          icon: Icons.bookmark_add_outlined,
                          accent: AppColors.primary,
                          actions: [
                            StatePanelAction(
                              label: 'Explore home',
                              icon: Icons.rocket_launch_rounded,
                              onPressed: () =>
                                  context.goNamed(AppRoutes.homeName),
                            ),
                            StatePanelAction(
                              label: 'Search NASA media',
                              icon: Icons.travel_explore_rounded,
                              onPressed: () =>
                                  context.pushNamed(AppRoutes.searchName),
                              emphasis: StatePanelActionEmphasis.secondary,
                            ),
                          ],
                        ),
                      if (!state.isLoading && !state.hasError && !state.isEmpty)
                        Column(
                          children: [
                            for (
                              var index = 0;
                              index < state.items.length;
                              index++
                            ) ...[
                              BookmarkContentCard(bookmark: state.items[index]),
                              if (index != state.items.length - 1)
                                const SizedBox(height: 18),
                            ],
                          ],
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
}

class _BookmarksLoadingView extends StatelessWidget {
  const _BookmarksLoadingView();

  @override
  Widget build(BuildContext context) {
    return SkeletonScope(
      child: Column(
        children: const [
          _BookmarkSkeletonCard(),
          SizedBox(height: 18),
          _BookmarkSkeletonCard(),
        ],
      ),
    );
  }
}

class _BookmarkSkeletonCard extends StatelessWidget {
  const _BookmarkSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final preview = const SkeletonBlock(height: 180, radius: 24);
          final text = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(width: 160, height: 16, radius: 10),
              SizedBox(height: 12),
              SkeletonBlock(width: 240, height: 24, radius: 12),
              SizedBox(height: 12),
              SkeletonLines(lines: 3),
              SizedBox(height: 16),
              SkeletonBlock(width: 180, height: 42, radius: 18),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [preview, const SizedBox(height: 16), text],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 240,
                child: SkeletonBlock(height: 150, radius: 24),
              ),
              const SizedBox(width: 16),
              Expanded(child: text),
            ],
          );
        },
      ),
    );
  }
}
