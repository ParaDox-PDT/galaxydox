import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/translation_language_sheet.dart';
import '../../domain/entities/apod_item.dart';
import '../providers/apod_article_translation_controller.dart';

class ApodArticleTranslationScope extends StatelessWidget {
  const ApodArticleTranslationScope({
    super.key,
    required this.item,
    required this.child,
  });

  final ApodItem item;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        currentApodTranslationItemProvider.overrideWithValue(item),
        apodArticleTranslationControllerProvider.overrideWith(
          ApodArticleTranslationController.new,
        ),
      ],
      child: child,
    );
  }
}

class ApodArticleMainPanel extends ConsumerWidget {
  const ApodArticleMainPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ApodArticleTranslationNotice?>(
      apodArticleTranslationControllerProvider.select((state) => state.notice),
      (previous, next) {
        if (next == null || previous?.id == next.id) {
          return;
        }

        _showSnackBar(context, message: next.message, isError: next.isError);
      },
    );

    final state = ref.watch(apodArticleTranslationControllerProvider);
    final item = state.originalItem;
    final theme = Theme.of(context);
    final targetLanguage = TranslationLanguageOptions.fromCode(
      state.targetLanguageCode,
    );

    return FrostedPanel(
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
              color: item.isVideo ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(state.displayedTitle, style: theme.textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text(
            DateFormat.yMMMMd().format(item.date),
            style: theme.textTheme.bodyLarge,
          ),
          if (state.isTranslationActive && targetLanguage != null) ...[
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => showTranslationLanguageSheet(context, ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        size: 16,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Translated to ${targetLanguage.label}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (state.isTranslating) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Translating article...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          const ApodTranslationActionButton(),
          const SizedBox(height: 22),
          Text(
            state.displayedExplanation,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: isError ? AppColors.error : AppColors.tertiary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      );
  }
}

class ApodTranslationActionButton extends ConsumerWidget {
  const ApodTranslationActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(apodArticleTranslationControllerProvider);
    final controller = ref.read(
      apodArticleTranslationControllerProvider.notifier,
    );
    final targetLanguage = TranslationLanguageOptions.fromCode(
      state.targetLanguageCode,
    );

    if (!state.isTranslationSupported) {
      return const SizedBox.shrink();
    }

    final onPressed = state.isTranslating
        ? null
        : state.isTranslationActive
        ? controller.showOriginal
        : controller.translate;

    final label = state.isTranslating
        ? 'Translating...'
        : state.isTranslationActive
        ? 'Show original'
        : 'Translate';

    final icon = state.isTranslating
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.textPrimary,
            ),
          )
        : Icon(
            state.isTranslationActive
                ? Icons.translate_outlined
                : Icons.translate_rounded,
          );

    final button = state.isTranslationActive
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label),
          );

    final helperText = targetLanguage == null
        ? 'Translation language unavailable.'
        : targetLanguage.isEnglish
        ? 'Translation is currently set to English.'
        : 'Translation language: ${targetLanguage.label}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Expanded(child: button)]),
        const SizedBox(height: 8),
        Text(
          helperText,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
