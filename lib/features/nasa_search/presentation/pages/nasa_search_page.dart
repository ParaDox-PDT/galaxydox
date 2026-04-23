import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/content_sliver_padding.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/premium_scrollbar.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/entities/nasa_media_item.dart';
import '../providers/nasa_search_controller.dart';
import '../widgets/nasa_media_result_card.dart';
import '../widgets/nasa_search_loading_view.dart';
import 'nasa_media_detail_page.dart';

class NasaSearchPage extends ConsumerStatefulWidget {
  const NasaSearchPage({super.key});

  @override
  ConsumerState<NasaSearchPage> createState() => _NasaSearchPageState();
}

class _NasaSearchPageState extends ConsumerState<NasaSearchPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nasaSearchControllerProvider);
    final controller = ref.read(nasaSearchControllerProvider.notifier);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: PremiumRefreshIndicator(
        onRefresh: controller.retry,
        child: PremiumScrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            cacheExtent: 1400,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              ContentSliverPadding(
                top: 12,
                sliver: SliverToBoxAdapter(
                  child: _TopBar(
                    onInfoPressed: () => _showResultsInfoSheet(context),
                    mediaTypeFilter: state.mediaTypeFilter,
                    searchController: _searchController,
                    onSubmit: () => _submitSearch(controller),
                    onExampleSelected: (query) =>
                        _selectExampleQuery(controller, query),
                    onClear: () => _clearSearch(controller),
                    onFilterChanged: _handleFilterChanged,
                  ).animate().fadeIn(duration: AppConstants.motionMedium),
                ),
              ),
              if (state.isIdle)
                ContentSliverPadding(
                  top: AppConstants.stackGap,
                  sliver: SliverToBoxAdapter(
                    child:
                        Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                _IntroPanel(),
                                SizedBox(height: AppConstants.stackGap),
                                _IdleState(),
                              ],
                            )
                            .animate()
                            .fadeIn(
                              delay: const Duration(milliseconds: 70),
                              duration: AppConstants.motionMedium,
                            )
                            .slideY(begin: 0.03, end: 0),
                  ),
                ),
              if (state.isLoading)
                const ContentSliverPadding(
                  top: AppConstants.stackGap,
                  sliver: SliverToBoxAdapter(child: NasaSearchLoadingView()),
                ),
              if (state.hasError)
                ContentSliverPadding(
                  top: AppConstants.stackGap,
                  sliver: SliverToBoxAdapter(
                    child: StatePanel(
                      title: 'Unable to load NASA search results',
                      message: state.error!.message,
                      icon: Icons.travel_explore_rounded,
                      accent: AppColors.warning,
                      actions: [
                        StatePanelAction(
                          label: 'Try again',
                          icon: Icons.refresh_rounded,
                          onPressed: controller.retry,
                        ),
                      ],
                    ),
                  ),
                ),
              if (state.isEmpty)
                ContentSliverPadding(
                  top: AppConstants.stackGap,
                  sliver: SliverToBoxAdapter(
                    child: StatePanel(
                      title: 'No results found',
                      message:
                          'NASA did not return matches for "${state.query}". Try a broader keyword, another media type, or refresh the search.',
                      icon: Icons.search_off_rounded,
                      accent: AppColors.secondary,
                      actions: [
                        StatePanelAction(
                          label: 'Retry',
                          icon: Icons.refresh_rounded,
                          onPressed: controller.retry,
                        ),
                      ],
                    ),
                  ),
                ),
              if (state.status == NasaSearchStatus.success &&
                  state.results.isNotEmpty)
                ..._buildResultSlivers(state),
              if (state.status != NasaSearchStatus.success ||
                  state.results.isEmpty)
                const SliverToBoxAdapter(child: SizedBox(height: 42)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResultSlivers(NasaSearchState state) {
    return [
      ContentSliverPadding(
        top: AppConstants.stackGap,
        sliver: SliverToBoxAdapter(child: const _ResultsHeader()),
      ),
      ContentSliverPadding(
        top: 18,
        bottom: 42,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = state.results[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == state.results.length - 1 ? 0 : 16,
              ),
              child: RepaintBoundary(
                child: NasaMediaResultCard(
                  key: ValueKey(item.nasaId),
                  item: item,
                  onTap: () => _openDetail(context, item),
                ),
              ),
            );
          }, childCount: state.results.length),
        ),
      ),
    ];
  }

  Future<void> _submitSearch(NasaSearchController controller) async {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    final query = _searchController.text;
    ref.read(analyticsServiceProvider).logSearchPerformed(query);
    await controller.search(query: query);
  }

  Future<void> _clearSearch(NasaSearchController controller) async {
    HapticFeedback.selectionClick();
    _searchController.clear();
    await controller.search(query: '');
  }

  Future<void> _selectExampleQuery(
    NasaSearchController controller,
    String query,
  ) async {
    HapticFeedback.selectionClick();
    _searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    ref.read(analyticsServiceProvider).logSearchPerformed(query);
    await controller.search(query: query);
  }

  Future<void> _handleFilterChanged(NasaSearchMediaFilter filter) async {
    HapticFeedback.selectionClick();
    await ref
        .read(nasaSearchControllerProvider.notifier)
        .setMediaTypeFilter(filter);
  }

  void _openDetail(BuildContext context, NasaMediaItem item) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      SwipeBackPageRoute<void>(
        builder: (context) => NasaMediaDetailPage(item: item),
      ),
    );
  }

  Future<void> _showResultsInfoSheet(BuildContext context) {
    final theme = Theme.of(context);

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDeep.withValues(alpha: 0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How NASA media search works',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'A quick explanation of what appears in this results feed.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FrostedPanel(
                  padding: const EdgeInsets.all(18),
                  borderColor: AppColors.primary.withValues(alpha: 0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Searches run against NASA\'s public media archive using your keyword plus the selected media type filter.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Results are shown as a single optimized list so it is easier to scan thumbnails, titles, dates, and descriptions without switching layouts.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Open any card to see the full details and, for videos, continue into playback when NASA provides a playable source.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onInfoPressed,
    required this.mediaTypeFilter,
    required this.searchController,
    required this.onSubmit,
    required this.onExampleSelected,
    required this.onClear,
    required this.onFilterChanged,
  });

  final VoidCallback onInfoPressed;
  final NasaSearchMediaFilter mediaTypeFilter;
  final TextEditingController searchController;
  final VoidCallback onSubmit;
  final ValueChanged<String> onExampleSelected;
  final VoidCallback onClear;
  final Future<void> Function(NasaSearchMediaFilter filter) onFilterChanged;

  static const _exampleQueries = [
    'James Webb',
    'Apollo 11',
    'Mars',
    'Nebula',
    'Artemis',
    'Saturn',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'NASA Media Search',
          subtitle:
              'Search across NASA imagery with a cinematic discovery surface.',
          actions: [
            IconButton(
              onPressed: onInfoPressed,
              tooltip: 'How search works',
              icon: const Icon(Icons.info_outline_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FrostedPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: searchController,
                                onSubmitted: (_) => onSubmit(),
                                textInputAction: TextInputAction.search,
                                maxLines: 1,
                                textAlignVertical: TextAlignVertical.center,
                                strutStyle: const StrutStyle(
                                  height: 1.15,
                                  forceStrutHeight: true,
                                ),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.15,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  hintText:
                                      'Search nebulae, Apollo, Hubble, Artemis...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: hasText
                                      ? IconButton(
                                          onPressed: onClear,
                                          icon: const Icon(Icons.close_rounded),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: AppConstants.motionFast,
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            child: hasText
                                ? Padding(
                                    key: const ValueKey('search-action'),
                                    padding: const EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: FilledButton(
                                        onPressed: onSubmit,
                                        style: FilledButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.search_rounded),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('search-action-hidden'),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 44,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _exampleQueries.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final query = _exampleQueries[index];
                              final isSelected =
                                  searchController.text.trim().toLowerCase() ==
                                  query.toLowerCase();

                              return ChoiceChip(
                                label: Text(query),
                                selected: isSelected,
                                onSelected: (_) => onExampleSelected(query),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _EqualSegmentedControl<NasaSearchMediaFilter>(
                value: mediaTypeFilter,
                items: const [
                  _SegmentItem(
                    value: NasaSearchMediaFilter.image,
                    label: 'Images',
                    icon: Icons.image_outlined,
                  ),
                  _SegmentItem(
                    value: NasaSearchMediaFilter.video,
                    label: 'Videos',
                    icon: Icons.play_circle_outline_rounded,
                  ),
                ],
                onChanged: onFilterChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentItem<T> {
  const _SegmentItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class _EqualSegmentedControl<T> extends StatelessWidget {
  const _EqualSegmentedControl({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<_SegmentItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    const gap = 4.0;
    final selectedIndex = items.indexWhere((item) => item.value == value);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth =
              (constraints.maxWidth - ((items.length - 1) * gap)) /
              items.length;
          final thumbLeft =
              (selectedIndex < 0 ? 0 : selectedIndex) * (segmentWidth + gap);

          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppConstants.motionMedium,
                curve: Curves.easeOutCubic,
                left: thumbLeft,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryStrong.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    Expanded(
                      child: _SegmentButton<T>(
                        item: items[index],
                        selected: items[index].value == value,
                        onTap: () => onChanged(items[index].value),
                        textStyle: theme.textTheme.labelLarge,
                      ),
                    ),
                    if (index != items.length - 1) const SizedBox(width: gap),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.textStyle,
  });

  final _SegmentItem<T> item;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: textStyle?.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find the right NASA media faster',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Search by mission, planet, telescope, astronaut, or keyword, then open the most relevant images and videos in the view that feels easiest to scan.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();

  @override
  Widget build(BuildContext context) {
    return const StatePanel(
      title: 'Start with a mission, telescope, or era',
      message:
          'Try searches like "nebula", "Apollo 11", "James Webb", or "Mars". Results will appear here as a fast-scanning media list.',
      icon: Icons.manage_search_rounded,
      accent: AppColors.primary,
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 1,
              color: AppColors.primaryStrong.withValues(alpha: 0.72),
            ),
            const SizedBox(width: 10),
            Text(
              'RESULTS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('NASA archive matches', style: theme.textTheme.headlineMedium),
      ],
    );
  }
}
