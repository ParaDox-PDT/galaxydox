import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/metadata_row.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/entities/mars_rover_photo.dart';
import '../providers/mars_rover_controller.dart';
import '../widgets/mars_rover_loading_view.dart';
import 'mars_rover_photo_detail_page.dart';

class MarsRoverPage extends ConsumerWidget {
  const MarsRoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marsRoverControllerProvider);
    final controller = ref.read(marsRoverControllerProvider.notifier);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: PremiumRefreshIndicator(
        onRefresh: controller.refresh,
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
                          title: 'Mars Rover',
                          subtitle: '${state.selectedRover.label} gallery',
                          actions: [
                            FilledButton.icon(
                              onPressed: controller.refresh,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh'),
                            ),
                          ],
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
                        _FilterPanel(
                              state: state,
                              onRoverSelected: controller.setRover,
                              onModeChanged: controller.setFilterMode,
                              onDatePick: () =>
                                  _pickDate(context, controller, state),
                              onApplySol: controller.setSol,
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 130),
                              duration: AppConstants.motionMedium,
                            )
                            .slideY(begin: 0.03, end: 0),
                        const SizedBox(height: 28),
                        if (state.isLoading) const MarsRoverLoadingView(),
                        if (state.hasError)
                          StatePanel(
                            title: 'Unable to load rover gallery',
                            message: state.error!.message,
                            icon: Icons.broken_image_outlined,
                            accent: AppColors.warning,
                            actions: [
                              StatePanelAction(
                                label: 'Try again',
                                icon: Icons.refresh_rounded,
                                onPressed: controller.refresh,
                              ),
                            ],
                          ),
                        if (state.isEmpty)
                          StatePanel(
                            title: 'No photos found',
                            message:
                                'NASA did not return rover photos for this filter combination. Try another date, a different sol, or switch to another rover.',
                            icon: Icons.image_search_rounded,
                            accent: AppColors.secondary,
                            actions: [
                              StatePanelAction(
                                label: 'Retry',
                                icon: Icons.refresh_rounded,
                                onPressed: controller.refresh,
                              ),
                              StatePanelAction(
                                label: 'Choose date',
                                icon: Icons.calendar_today_rounded,
                                onPressed: () =>
                                    _pickDate(context, controller, state),
                                emphasis: StatePanelActionEmphasis.secondary,
                              ),
                            ],
                          ),
                        if (state.status == MarsRoverStatus.success &&
                            state.photos.isNotEmpty)
                          _GalleryContent(photos: state.photos),
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

  Future<void> _pickDate(
    BuildContext context,
    MarsRoverController controller,
    MarsRoverState state,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.earthDate,
      firstDate: DateTime(2004, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primaryStrong,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
      await controller.setEarthDate(picked);
    }
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
                'A premium Mars image archive',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Switch between rovers, explore by Earth date or Martian sol, and open any frame into an image-first detail experience with metadata that stays readable.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              AppChip(label: 'Rover-aware'),
              AppChip(label: 'Earth date filter'),
              AppChip(label: 'Sol filter'),
              AppChip(label: 'Image detail viewer'),
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

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({
    required this.state,
    required this.onRoverSelected,
    required this.onModeChanged,
    required this.onDatePick,
    required this.onApplySol,
  });

  final MarsRoverState state;
  final Future<void> Function(MarsRoverName rover) onRoverSelected;
  final Future<void> Function(MarsRoverFilterMode mode) onModeChanged;
  final VoidCallback onDatePick;
  final Future<void> Function(int sol) onApplySol;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late final TextEditingController _solController;

  @override
  void initState() {
    super.initState();
    _solController = TextEditingController(text: widget.state.sol.toString());
  }

  @override
  void didUpdateWidget(covariant _FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.sol != widget.state.sol) {
      _solController.text = widget.state.sol.toString();
    }
  }

  @override
  void dispose() {
    _solController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: theme.textTheme.titleLarge),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final rover in MarsRoverName.values)
                ChoiceChip(
                  label: Text(rover.label),
                  selected: widget.state.selectedRover == rover,
                  onSelected: (_) => widget.onRoverSelected(rover),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Earth date'),
                selected:
                    widget.state.filterMode == MarsRoverFilterMode.earthDate,
                onSelected: (_) =>
                    widget.onModeChanged(MarsRoverFilterMode.earthDate),
              ),
              ChoiceChip(
                label: const Text('Sol'),
                selected: widget.state.filterMode == MarsRoverFilterMode.sol,
                onSelected: (_) =>
                    widget.onModeChanged(MarsRoverFilterMode.sol),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (widget.state.filterMode == MarsRoverFilterMode.earthDate)
            OutlinedButton.icon(
              onPressed: widget.onDatePick,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(
                'Earth date: ${DateFormat.yMMMd().format(widget.state.earthDate)}',
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;

                final field = SizedBox(
                  width: compact ? constraints.maxWidth : 220,
                  child: TextField(
                    controller: _solController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sol',
                      hintText: 'Enter Martian sol',
                    ),
                  ),
                );

                final button = FilledButton.icon(
                  onPressed: () async {
                    final sol = int.tryParse(_solController.text.trim());
                    if (sol == null || sol < 0) {
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a valid non-negative sol value.',
                          ),
                        ),
                      );
                      return;
                    }
                    HapticFeedback.selectionClick();
                    await widget.onApplySol(sol);
                  },
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Apply sol'),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [field, const SizedBox(height: 12), button],
                  );
                }

                return Row(
                  children: [field, const SizedBox(width: 12), button],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GalleryContent extends StatelessWidget {
  const _GalleryContent({required this.photos});

  final List<MarsRoverPhoto> photos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Gallery',
          title: 'Surface frames from Mars',
          subtitle:
              'Each card keeps the frame front and center while preserving the mission metadata that gives it context.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 1080
                ? 3
                : constraints.maxWidth >= 720
                ? 2
                : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: crossAxisCount == 1 ? 1.08 : 0.82,
              ),
              itemBuilder: (context, index) {
                return _PhotoCard(photo: photos[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.photo});

  final MarsRoverPhoto photo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'mars-rover-photo-${photo.id}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                SwipeBackPageRoute<void>(
                  builder: (context) =>
                      MarsRoverPhotoDetailPage(photo: photo, heroTag: heroTag),
                ),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceElevated.withValues(alpha: 0.92),
                    AppColors.surface.withValues(alpha: 0.98),
                  ],
                ),
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: PremiumNetworkImage(
                            imageUrl: photo.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: BookmarkButton(
                            bookmark: BookmarkMapper.fromMarsRoverPhoto(photo),
                            savedLabel: 'Bookmarked',
                            unsavedLabel: 'Bookmark',
                            variant: BookmarkButtonVariant.icon,
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated.withValues(
                                alpha: 0.64,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall,
                              ),
                              border: Border.all(color: AppColors.outlineSoft),
                            ),
                            child: Text(
                              photo.cameraFullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            photo.roverName,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMMd().format(photo.earthDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          MetadataRow(label: 'Camera', value: photo.cameraName),
                          const SizedBox(height: 10),
                          MetadataRow(
                            label: 'Status',
                            value: photo.roverStatus,
                          ),
                          const SizedBox(height: 10),
                          MetadataRow(
                            label: 'Sol',
                            value: photo.sol.toString(),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Open detail',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_outward_rounded,
                                color: AppColors.secondary,
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
