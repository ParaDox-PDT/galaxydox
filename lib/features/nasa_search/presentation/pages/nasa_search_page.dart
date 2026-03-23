import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_chip.dart';
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
    required this.onClear,
    required this.onToggleView,
    required this.onFilterChanged,
  });

  final NasaSearchState state;
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final ValueChanged<NasaSearchViewMode> onToggleView;
  final Future<void> Function(NasaSearchMediaFilter filter) onFilterChanged;

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
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  return TextField(
                    controller: searchController,
                    onChanged: onChanged,
                    onSubmitted: (_) => onSubmit(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search nebulae, Apollo, Hubble, Artemis...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              onPressed: onClear,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  final filterRow = Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final filter in NasaSearchMediaFilter.values)
                        ChoiceChip(
                          label: Text(filter.label),
                          selected: state.mediaTypeFilter == filter,
                          onSelected: (_) => onFilterChanged(filter),
                        ),
                    ],
                  );

                  final actions = Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SegmentedButton<NasaSearchViewMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: NasaSearchViewMode.grid,
                            icon: Icon(Icons.grid_view_rounded),
                            label: Text('Grid'),
                          ),
                          ButtonSegment(
                            value: NasaSearchViewMode.list,
                            icon: Icon(Icons.view_agenda_rounded),
                            label: Text('List'),
                          ),
                        ],
                        selected: {state.viewMode},
                        onSelectionChanged: (selection) {
                          onToggleView(selection.first);
                        },
                      ),
                      FilledButton.icon(
                        onPressed: onSubmit,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Search'),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filterRow,
                        const SizedBox(height: 14),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: filterRow),
                      const SizedBox(width: 12),
                      actions,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
                'Editorial discovery for NASA archives',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Debounced input keeps the experience responsive, while grid and list modes let users browse dense visual results in the format that fits the moment.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              AppChip(label: 'Debounced input'),
              AppChip(label: 'Grid and list views'),
              AppChip(label: 'Detail page'),
              AppChip(label: 'Image and video aware'),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [lead, const SizedBox(height: 18), chips],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: lead),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: chips),
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
