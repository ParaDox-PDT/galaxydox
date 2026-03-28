import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/trusted_external_url.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/metadata_row.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/entities/apod_item.dart';
import '../providers/apod_controller.dart';
import '../widgets/apod_loading_view.dart';
import '../widgets/apod_media_preview.dart';

class ApodPage extends ConsumerWidget {
  const ApodPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(apodControllerProvider);
    final controller = ref.read(apodControllerProvider.notifier);

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
                    maxWidth: AppConstants.contentMaxWidthCompact,
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
                          title: 'APOD',
                          subtitle: state.selectedDate == null
                              ? 'Astronomy Picture of the Day'
                              : 'Viewing ${DateFormat.yMMMMd().format(state.selectedDate!)}',
                          actions: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _pickDate(context, controller, state),
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: const Text('Choose date'),
                            ),
                            FilledButton.icon(
                              onPressed: controller.refresh,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ).animate().fadeIn(duration: AppConstants.motionMedium),
                        const SizedBox(height: AppConstants.stackGap),
                        const _ApodIntro()
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 80),
                              duration: AppConstants.motionMedium,
                            )
                            .slideY(begin: 0.03, end: 0),
                        const SizedBox(height: 28),
                        if (state.isLoading) const ApodLoadingView(),
                        if (state.hasError)
                          StatePanel(
                            title: 'Unable to load APOD',
                            message: state.error!.message,
                            icon: Icons.wifi_tethering_error_rounded,
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
                            title: 'No APOD entry found',
                            message:
                                'NASA did not return an APOD entry for this date. Try refreshing or choose another day from the archive.',
                            icon: Icons.auto_awesome_motion_rounded,
                            accent: AppColors.secondary,
                            actions: [
                              StatePanelAction(
                                label: 'Retry',
                                icon: Icons.refresh_rounded,
                                onPressed: controller.refresh,
                              ),
                              StatePanelAction(
                                label: 'Choose another date',
                                icon: Icons.calendar_today_rounded,
                                onPressed: () =>
                                    _pickDate(context, controller, state),
                                emphasis: StatePanelActionEmphasis.secondary,
                              ),
                            ],
                          ),
                        if (state.status == ApodStatus.success &&
                            state.item != null)
                          _ApodContent(item: state.item!),
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
    ApodController controller,
    ApodState state,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? now,
      firstDate: DateTime(1995, 6, 16),
      lastDate: now,
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
      await controller.selectDate(picked);
    }
  }
}

class _ApodIntro extends StatelessWidget {
  const _ApodIntro();

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
                'NASA\'s daily headline image',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Each APOD entry can be an image or a video, paired with context that turns it into a story rather than just a media asset.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              AppChip(label: 'Image and video aware'),
              AppChip(label: 'HD-friendly'),
              AppChip(label: 'Full-screen viewer'),
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

class _ApodContent extends StatelessWidget {
  const _ApodContent({required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMMd().format(item.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ApodMediaPreview(item: item)
            .animate()
            .fadeIn(duration: AppConstants.motionSlow)
            .slideY(begin: 0.04, end: 0),
        const SizedBox(height: AppConstants.stackGap),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;

            final main = FrostedPanel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.mediaType == ApodMediaType.video
                        ? 'NASA video of the day'
                        : item.hasHdImage
                        ? 'HD astronomy image'
                        : 'Astronomy image',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: item.isVideo
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(item.title, style: theme.textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(formattedDate, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 22),
                  Text(
                    item.explanation,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            );

            final side = Column(
              children: [
                _MetaPanel(item: item),
                const SizedBox(height: 18),
                _ActionPanel(item: item),
              ],
            );

            if (compact) {
              return Column(children: [main, const SizedBox(height: 18), side]);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: main),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: side),
              ],
            );
          },
        ),
        const SizedBox(height: AppConstants.stackGap),
        SectionHeading(
          eyebrow: 'Context',
          title: 'Why this APOD matters',
          subtitle:
              'The explanation is the editorial core of APOD. It turns a single daily entry into something educational, reflective, and worth revisiting.',
        ),
        const SizedBox(height: 18),
        FrostedPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reader notes', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'APOD is strongest when it balances wonder with context. GalaxyDox keeps the narrative front and center while still surfacing the media format, date, and attribution details that matter.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaPanel extends StatelessWidget {
  const _MetaPanel({required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metadata', style: theme.textTheme.titleLarge),
          const SizedBox(height: 18),
          MetadataRow(
            label: 'Date',
            value: DateFormat.yMMMd().format(item.date),
          ),
          const SizedBox(height: 14),
          MetadataRow(
            label: 'Media type',
            value: item.isVideo ? 'Video' : 'Image',
          ),
          const SizedBox(height: 14),
          MetadataRow(
            label: 'HD available',
            value: item.hasHdImage ? 'Yes' : 'No',
          ),
          if ((item.copyright ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            MetadataRow(label: 'Credit', value: item.copyright!),
          ],
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: BookmarkButton(bookmark: BookmarkMapper.fromApod(item)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareApod(context),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
          if (item.isImage && item.hasHdImage) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openHdImage(context),
                    icon: const Icon(Icons.hd_rounded),
                    label: const Text('Open HD'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _shareApod(BuildContext context) async {
    final shareUri = sanitizeTrustedExternalUri(
      item.isImage ? item.preferredImageUrl : item.url,
      allowedHosts: TrustedHostSets.nasaAndVideoHosts,
    );
    final explanation = item.explanation.trim();
    final shortExplanation = explanation.length > 180
        ? '${explanation.substring(0, 177)}...'
        : explanation;

    final buffer = StringBuffer()
      ..writeln(item.title)
      ..writeln(DateFormat.yMMMMd().format(item.date))
      ..writeln()
      ..writeln(shortExplanation);

    if (shareUri != null) {
      buffer
        ..writeln()
        ..write(shareUri.toString());
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString().trim()));
  }

  Future<void> _openHdImage(BuildContext context) async {
    final uri = sanitizeTrustedExternalUri(
      item.hdUrl ?? item.preferredImageUrl,
      allowedHosts: TrustedHostSets.nasaHosts,
    );
    if (uri == null) {
      _showLaunchError(context);
      return;
    }

    final launched = await launchExternalUri(uri);
    if (!launched && context.mounted) {
      _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the NASA media link.')),
    );
  }
}
