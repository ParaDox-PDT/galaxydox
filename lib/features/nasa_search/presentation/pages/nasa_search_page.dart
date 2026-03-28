import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/section_heading.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
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
                        _TopBar(
                          state: state,
                          searchController: _searchController,
                          onChanged: _onSearchChanged,
                          onSubmit: () => _submitSearch(controller),
                          onExampleSelected: (query) =>
                              _selectExampleQuery(controller, query),
                          onClear: () => _clearSearch(controller),
                          onToggleView: _handleViewToggle,
                          onFilterChanged: _handleFilterChanged,
                        ).animate().fadeIn(duration: AppConstants.motionMedium),
                        const SizedBox(height: AppConstants.stackGap),
                        const _IntroPanel()
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 70),
                              duration: AppConstants.motionMedium,
                            )
                            .slideY(begin: 0.03, end: 0),
                        const SizedBox(height: AppConstants.stackGap),
                        if (state.isIdle) const _IdleState(),
                        if (state.isLoading)
                          NasaSearchLoadingView(viewMode: state.viewMode),
                        if (state.hasError)
                          StatePanel(
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
                        if (state.isEmpty)
                          StatePanel(
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
                        if (state.status == NasaSearchStatus.success &&
                            state.results.isNotEmpty)
                          _SearchResults(
                            state: state,
                            onItemTap: (item) => _openDetail(context, item),
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 550), () {
      ref.read(nasaSearchControllerProvider.notifier).search(query: value);
    });
  }

  Future<void> _submitSearch(NasaSearchController controller) async {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    await controller.search(query: _searchController.text);
  }

  Future<void> _clearSearch(NasaSearchController controller) async {
    _debounce?.cancel();
    HapticFeedback.selectionClick();
    _searchController.clear();
    await controller.search(query: '');
  }

  Future<void> _selectExampleQuery(
    NasaSearchController controller,
    String query,
  ) async {
    _debounce?.cancel();
    HapticFeedback.selectionClick();
    _searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    await controller.search(query: query);
  }

  void _handleViewToggle(NasaSearchViewMode viewMode) {
    HapticFeedback.selectionClick();
    ref.read(nasaSearchControllerProvider.notifier).setViewMode(viewMode);
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
      MaterialPageRoute<void>(
        builder: (context) => NasaMediaDetailPage(item: item),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.state,
    required this.searchController,
    required this.onChanged,
    required this.onSubmit,
    required this.onExampleSelected,
    required this.onClear,
    required this.onToggleView,
    required this.onFilterChanged,
  });

  final NasaSearchState state;
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final ValueChanged<String> onExampleSelected;
  final VoidCallback onClear;
  final ValueChanged<NasaSearchViewMode> onToggleView;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'NASA Media Search',
          subtitle:
              'Search across NASA imagery with a cinematic discovery surface.',
          actions: [],
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
                                onChanged: onChanged,
                                onSubmitted: (_) => onSubmit(),
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
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
                value: state.mediaTypeFilter,
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
                onChanged: (filter) {
                  onFilterChanged(filter);
                },
              ),
              const SizedBox(height: 14),
              _EqualSegmentedControl<NasaSearchViewMode>(
                value: state.viewMode,
                items: const [
                  _SegmentItem(
                    value: NasaSearchViewMode.grid,
                    label: 'Grid',
                    icon: Icons.grid_view_rounded,
                  ),
                  _SegmentItem(
                    value: NasaSearchViewMode.list,
                    label: 'List',
                    icon: Icons.view_agenda_rounded,
                  ),
                ],
                onChanged: onToggleView,
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
          final compact = constraints.maxWidth < 860;
          final theme = Theme.of(context);

          final lead = Column(
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

          if (compact) {
            return lead;
          }

          return lead;
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
          'Try searches like "nebula", "Apollo 11", "James Webb", or "Mars". Results will appear here with a premium gallery layout.',
      icon: Icons.manage_search_rounded,
      accent: AppColors.primary,
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onItemTap});

  final NasaSearchState state;
  final ValueChanged<NasaMediaItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Results',
          title: 'NASA archive matches',
          subtitle:
              'The layout shifts between a gallery-first grid and a more editorial list, while keeping the search metadata easy to scan.',
        ),
        const SizedBox(height: 18),
        if (state.viewMode == NasaSearchViewMode.grid)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1100
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : constraints.maxWidth >= 340
                  ? 2
                  : 1;
              final childAspectRatio = switch (crossAxisCount) {
                3 => 0.76,
                2 => constraints.maxWidth >= 640 ? 0.74 : 0.62,
                _ => 0.96,
              };
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.results.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final item = state.results[index];
                  return NasaMediaResultCard(
                    item: item,
                    viewMode: state.viewMode,
                    onTap: () => onItemTap(item),
                  );
                },
              );
            },
          )
        else
          Column(
            children: [
              for (var index = 0; index < state.results.length; index++) ...[
                NasaMediaResultCard(
                  item: state.results[index],
                  viewMode: state.viewMode,
                  onTap: () => onItemTap(state.results[index]),
                ),
                if (index != state.results.length - 1)
                  const SizedBox(height: 16),
              ],
            ],
          ),
      ],
    );
  }
}
