import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/space_scaffold.dart';
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
                Text('Settings', style: theme.textTheme.displayMedium),
                const SizedBox(height: 10),
                Text(
                  'GalaxyDox keeps privacy and core app actions easy to reach without clutter.',
                  style: theme.textTheme.bodyLarge,
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
                              _showTranslationLanguageSheet(context, ref),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).maybePop();
                            return;
                          }

                          context.goNamed(AppRoutes.homeName);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Return to Home'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTranslationLanguageSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selected = ref.read(apodTranslationLanguageProvider);
    final picked = await showModalBottomSheet<TranslationLanguageOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TranslationLanguageSheet(selected: selected);
      },
    );

    if (picked == null) {
      return;
    }

    await ref
        .read(apodTranslationLanguageProvider.notifier)
        .setLanguage(picked);
  }
}

class _TranslationLanguageSheet extends StatelessWidget {
  const _TranslationLanguageSheet({required this.selected});

  final TranslationLanguageOption selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languages = [
      TranslationLanguageOptions.russian,
      ...TranslationLanguageOptions.values
          .where(
            (language) =>
                language.code != TranslationLanguageOptions.russian.code,
          )
          .toList()
        ..sort((left, right) => left.label.compareTo(right.label)),
    ];

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose translation language',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = language.code == selected.code;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(language.label),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded)
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(language),
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(height: 6),
                itemCount: languages.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
