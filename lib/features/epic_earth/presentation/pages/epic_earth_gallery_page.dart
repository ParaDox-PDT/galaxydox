import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../cubit/epic_earth_cubit.dart';
import '../cubit/epic_earth_state.dart';
import '../widgets/epic_date_selector.dart';
import '../widgets/epic_earth_loading_view.dart';
import '../widgets/epic_gallery_grid.dart';

class EpicEarthGalleryPage extends ConsumerWidget {
  const EpicEarthGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) => EpicEarthCubit(
        getLatestEpicImagesUseCase: ref.watch(
          getLatestEpicImagesUseCaseProvider,
        ),
        getAvailableEpicDatesUseCase: ref.watch(
          getAvailableEpicDatesUseCaseProvider,
        ),
        getEpicImagesByDateUseCase: ref.watch(
          getEpicImagesByDateUseCaseProvider,
        ),
      )..loadLatest(),
      child: const _EpicEarthGalleryView(),
    );
  }
}

class _EpicEarthGalleryView extends StatelessWidget {
  const _EpicEarthGalleryView();

  @override
  Widget build(BuildContext context) {
    return SpaceScaffold(
      bottomSafeArea: true,
      body: BlocBuilder<EpicEarthCubit, EpicEarthState>(
        builder: (context, state) {
          final cubit = context.read<EpicEarthCubit>();

          return PremiumRefreshIndicator(
            onRefresh: cubit.refresh,
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
                            const _InlineBackHeader().animate().fadeIn(
                              duration: AppConstants.motionMedium,
                            ),
                            const SizedBox(height: 18),
                            _EpicPageHeader(
                              title: 'Earth from L1',
                              subtitle: 'Natural-color DSCOVR EPIC imagery',
                            ).animate().fadeIn(
                              duration: AppConstants.motionMedium,
                            ),
                            const SizedBox(height: AppConstants.stackGap),
                            EpicDateSelector(
                                  state: state,
                                  onPickDate: () =>
                                      _pickDate(context, cubit, state),
                                  onLoadLatest: cubit.loadLatest,
                                  onDateSelected: (date) {
                                    HapticFeedback.selectionClick();
                                    cubit.selectDate(date);
                                  },
                                )
                                .animate()
                                .fadeIn(
                                  delay: const Duration(milliseconds: 80),
                                  duration: AppConstants.motionMedium,
                                )
                                .slideY(begin: 0.03, end: 0),
                            const SizedBox(height: 28),
                            if (state.isLoading) const EpicEarthLoadingView(),
                            if (state.hasError)
                              StatePanel(
                                title: 'Unable to load Earth gallery',
                                message: state.error!.message,
                                icon: Icons.public_off_rounded,
                                accent: AppColors.error,
                                actions: [
                                  StatePanelAction(
                                    label: 'Try again',
                                    icon: Icons.refresh_rounded,
                                    onPressed: cubit.refresh,
                                  ),
                                ],
                              ),
                            if (state.isEmpty)
                              StatePanel(
                                title: 'No EPIC images found',
                                message:
                                    'NASA did not return natural-color EPIC images for this date.',
                                icon: Icons.image_search_rounded,
                                accent: AppColors.tertiary,
                                actions: [
                                  StatePanelAction(
                                    label: 'Choose date',
                                    icon: Icons.calendar_month_rounded,
                                    onPressed: () =>
                                        _pickDate(context, cubit, state),
                                  ),
                                  StatePanelAction(
                                    label: 'Latest',
                                    icon: Icons.public_rounded,
                                    onPressed: cubit.loadLatest,
                                    emphasis:
                                        StatePanelActionEmphasis.secondary,
                                  ),
                                ],
                              ),
                            if (state.status == EpicEarthStatus.loaded &&
                                state.images.isNotEmpty)
                              EpicGalleryGrid(images: state.images),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    EpicEarthCubit cubit,
    EpicEarthState state,
  ) async {
    final initialDate = _initialPickerDate(state);
    final firstDate = state.availableDates.isEmpty
        ? DateTime(2015, 6, 13)
        : state.availableDates.last;
    final lastDate = state.availableDates.isEmpty
        ? DateTime.now()
        : state.availableDates.first;
    final availableDateKeys = state.availableDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: state.availableDates.isEmpty
          ? null
          : (date) => availableDateKeys.contains(
              DateTime(date.year, date.month, date.day),
            ),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.tertiary,
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

    if (picked == null || !context.mounted) {
      return;
    }

    HapticFeedback.selectionClick();
    await cubit.selectDate(picked);
  }

  DateTime _initialPickerDate(EpicEarthState state) {
    final selectedDate = state.selectedDate;
    if (selectedDate != null &&
        (state.availableDates.isEmpty ||
            state.availableDates.any((date) => _sameDay(date, selectedDate)))) {
      return selectedDate;
    }

    if (state.availableDates.isNotEmpty) {
      return state.availableDates.first;
    }

    return DateTime.now();
  }

  static bool _sameDay(DateTime date, DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}

class _InlineBackHeader extends StatelessWidget {
  const _InlineBackHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'EPIC Earth Gallery',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _EpicPageHeader extends StatelessWidget {
  const _EpicPageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
