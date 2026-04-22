import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/trusted_external_url.dart';
import '../../../../shared/bookmarks/bookmark_mapper.dart';
import '../../../../shared/widgets/bookmark_button.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/metadata_row.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../domain/entities/apod_item.dart';
import '../utils/apod_video_launcher.dart';
import '../widgets/apod_media_preview.dart';

class ApodDetailPage extends StatelessWidget {
  const ApodDetailPage({super.key, required this.item});

  final ApodItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                        title: 'Saved APOD',
                        subtitle: DateFormat.yMMMMd().format(item.date),
                        actions: [
                          BookmarkButton(
                            bookmark: BookmarkMapper.fromApod(item),
                            unsavedLabel: 'Bookmark',
                            savedLabel: 'Bookmarked',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.stackGap),
                      ApodMediaPreview(item: item),
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
                                  item.isVideo
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
                                Text(
                                  item.title,
                                  style: theme.textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  DateFormat.yMMMMd().format(item.date),
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  item.explanation,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textPrimary.withValues(
                                      alpha: 0.84,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          final side = Column(
                            children: [
                              _ApodMetadataPanel(item: item),
                              const SizedBox(height: 18),
                              _ApodActionPanel(item: item),
                            ],
                          );

                          if (compact) {
                            return Column(
                              children: [
                                main,
                                const SizedBox(height: 18),
                                side,
                              ],
                            );
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
                      const SectionHeading(
                        eyebrow: 'Context',
                        title: 'Why this APOD matters',
                        subtitle:
                            'Saved APOD entries stay readable and revisit-friendly, preserving the narrative and media context even after the live page moves on to a new date.',
                      ),
                      const SizedBox(height: 18),
                      FrostedPanel(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reader notes',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This saved view keeps the editorial rhythm of the original APOD experience while letting bookmarks reopen instantly from local storage.',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
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

class _ApodMetadataPanel extends StatelessWidget {
  const _ApodMetadataPanel({required this.item});

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

class _ApodActionPanel extends StatelessWidget {
  const _ApodActionPanel({required this.item});

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
          if (item.isVideo) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => openApodVideoPlayer(context, item: item),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('Open video'),
                  ),
                ),
              ],
            ),
          ],
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
