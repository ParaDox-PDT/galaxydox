import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/translation_language_sheet.dart';
import '../providers/translation_language_settings_controller.dart';
import 'privacy_notice_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final translationLanguage = ref.watch(apodTranslationLanguageProvider);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Settings',
                  subtitle:
                      'GalaxyDox keeps privacy and core app actions easy to reach without clutter.',
                  actions: [],
                ),
                const SizedBox(height: 20),
                FrostedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy at a glance',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The app stores bookmarks only on-device, sends NASA search and content requests directly to NASA services, and does not include ads, analytics SDKs, or account sign-in.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                SwipeBackPageRoute<void>(
                                  builder: (context) =>
                                      const PrivacyNoticePage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.privacy_tip_outlined),
                            label: const Text('Privacy notice'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.pushNamed(AppRoutes.bookmarksName),
                            icon: const Icon(Icons.bookmarks_rounded),
                            label: const Text('Bookmarks'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FrostedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () =>
                              showTranslationLanguageSheet(context, ref),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                const Icon(Icons.translate_rounded),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Translation language',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        translationLanguage.label,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Articles and other supported app content will be translated into this language when available.',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
