import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/translation/translation_language_options.dart';
import '../../features/settings/presentation/providers/translation_language_settings_controller.dart';

/// Opens the language picker bottom sheet and saves the selection.
/// Usable from any [ConsumerWidget] that has a [BuildContext] and [WidgetRef].
Future<TranslationLanguageOption?> showTranslationLanguageSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final selected = ref.read(apodTranslationLanguageProvider);
  final picked = await showModalBottomSheet<TranslationLanguageOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TranslationLanguageSheet(selected: selected),
  );
  if (picked == null) return null;
  if (!context.mounted) return null;
  await ref.read(apodTranslationLanguageProvider.notifier).setLanguage(picked);
  return picked;
}

class TranslationLanguageSheet extends StatelessWidget {
  const TranslationLanguageSheet({super.key, required this.selected});

  final TranslationLanguageOption selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languages = [
      TranslationLanguageOptions.russian,
      ...TranslationLanguageOptions.values
          .where((l) => l.code != TranslationLanguageOptions.russian.code)
          .toList()
        ..sort((a, b) => a.label.compareTo(b.label)),
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
                    subtitle: language.nativeName == language.label
                        ? null
                        : Text(language.nativeName),
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
