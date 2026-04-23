import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../../../settings/presentation/providers/translation_language_settings_controller.dart';
import '../../data/repositories/apod_translation_repository_impl.dart';
import '../../domain/entities/apod_article_translation.dart';
import '../../domain/entities/apod_item.dart';
import '../../domain/usecases/translate_apod_article.dart';

final currentApodTranslationItemProvider = Provider<ApodItem>((ref) {
  throw UnimplementedError('An APOD item override is required.');
});

final translateApodArticleUseCaseProvider =
    Provider<TranslateApodArticleUseCase>((ref) {
      return TranslateApodArticleUseCase(
        ref.watch(apodTranslationRepositoryProvider),
      );
    });

final apodArticleTranslationControllerProvider =
    NotifierProvider.autoDispose<
      ApodArticleTranslationController,
      ApodArticleTranslationState
    >(ApodArticleTranslationController.new);

class ApodArticleTranslationController
    extends Notifier<ApodArticleTranslationState> {
  late final TranslateApodArticleUseCase _translateApodArticleUseCase;
  late ApodItem _item;
  late String _targetLanguageCode;
  int _requestVersion = 0;

  @override
  ApodArticleTranslationState build() {
    _translateApodArticleUseCase = ref.watch(
      translateApodArticleUseCaseProvider,
    );
    final item = ref.watch(currentApodTranslationItemProvider);
    final targetLanguage = ref.read(apodTranslationLanguageProvider);
    final previousState = stateOrNull;
    final isSameArticle =
        previousState != null &&
        _isSameArticle(previousState.originalItem, item);

    _item = item;
    _targetLanguageCode = targetLanguage.code;

    ref.listen<TranslationLanguageOption>(apodTranslationLanguageProvider, (
      previous,
      next,
    ) {
      if (previous?.code == next.code) {
        return;
      }

      _handleTargetLanguageChanged(next.code);
    });

    if (isSameArticle) {
      final translation = previousState.translatedContent;
      final hasCurrentTranslation =
          translation != null &&
          translation.targetLanguageCode == targetLanguage.code;

      return previousState.copyWith(
        originalItem: item,
        targetLanguageCode: targetLanguage.code,
        isTranslationSupported:
            _translateApodArticleUseCase.isTranslationSupported,
        translatedContent: hasCurrentTranslation ? translation : null,
        isTranslationActive: hasCurrentTranslation
            ? previousState.isTranslationActive
            : false,
        clearTranslatedContent: !hasCurrentTranslation,
        clearError: true,
        clearNotice: true,
      );
    }

    _requestVersion++;
    return ApodArticleTranslationState.initial(
      originalItem: item,
      targetLanguageCode: targetLanguage.code,
      isTranslationSupported:
          _translateApodArticleUseCase.isTranslationSupported,
    );
  }

  Future<void> translate() async {
    if (state.isTranslating) {
      return;
    }

    if (!state.isTranslationSupported) {
      state = state.copyWith(
        notice: ApodArticleTranslationNotice.error(
          'On-device translation is available on Android and iOS only.',
        ),
        clearError: true,
      );
      return;
    }

    final targetLanguage =
        TranslationLanguageOptions.fromCode(_targetLanguageCode) ??
        TranslationLanguageOptions.english;
    if (targetLanguage.isEnglish) {
      state = state.copyWith(
        notice: ApodArticleTranslationNotice.info(
          'Set a different translation language in Settings to translate this article.',
        ),
        clearError: true,
      );
      return;
    }

    final currentTranslation = state.translatedContent;
    if (state.isTranslationActive &&
        currentTranslation != null &&
        currentTranslation.targetLanguageCode == _targetLanguageCode) {
      return;
    }

    final requestVersion = ++_requestVersion;
    state = state.copyWith(
      isTranslating: true,
      clearError: true,
      clearNotice: true,
      clearTranslatedContent:
          currentTranslation != null &&
          currentTranslation.targetLanguageCode != _targetLanguageCode,
      isTranslationActive:
          currentTranslation != null &&
          currentTranslation.targetLanguageCode == _targetLanguageCode &&
          state.isTranslationActive,
    );

    final result = await _translateApodArticleUseCase(
      item: _item,
      targetLanguageCode: _targetLanguageCode,
    );
    if (!ref.mounted || requestVersion != _requestVersion) {
      return;
    }

    state = result.when(
      success: (translation) {
        return state.copyWith(
          translatedContent: translation,
          isTranslationActive: true,
          isTranslating: false,
          clearError: true,
          notice: ApodArticleTranslationNotice.info(
            'Tap the language indicator above to switch languages.',
          ),
        );
      },
      failure: (exception) {
        return state.copyWith(
          isTranslating: false,
          isTranslationActive: false,
          error: exception,
          notice: ApodArticleTranslationNotice.error(
            exception.message.isEmpty
                ? 'Failed to translate article.'
                : exception.message,
          ),
        );
      },
    );
  }

  void showOriginal() {
    if (state.isTranslating) {
      return;
    }

    state = state.copyWith(
      isTranslationActive: false,
      clearError: true,
      clearNotice: true,
    );
  }

  void _handleTargetLanguageChanged(String nextLanguageCode) {
    final previousState = state;
    final previousTranslation = previousState.translatedContent;
    final hadActiveTranslation = previousState.isTranslationActive;
    final hasCurrentTranslation =
        previousTranslation != null &&
        previousTranslation.targetLanguageCode == nextLanguageCode;

    _targetLanguageCode = nextLanguageCode;
    _requestVersion++;

    state = previousState.copyWith(
      targetLanguageCode: nextLanguageCode,
      translatedContent: hasCurrentTranslation ? previousTranslation : null,
      clearTranslatedContent: !hasCurrentTranslation,
      isTranslationActive: hasCurrentTranslation
          ? previousState.isTranslationActive
          : false,
      isTranslating: false,
      clearError: true,
      clearNotice: true,
    );

    final targetLanguage =
        TranslationLanguageOptions.fromCode(nextLanguageCode) ??
        TranslationLanguageOptions.english;
    if (hadActiveTranslation && !targetLanguage.isEnglish) {
      unawaited(translate());
    }
  }

  bool _isSameArticle(ApodItem left, ApodItem right) {
    return left.date == right.date &&
        left.title == right.title &&
        left.explanation == right.explanation &&
        left.url == right.url &&
        left.hdUrl == right.hdUrl &&
        left.thumbnailUrl == right.thumbnailUrl &&
        left.mediaType == right.mediaType &&
        left.copyright == right.copyright;
  }
}

class ApodArticleTranslationState {
  const ApodArticleTranslationState({
    required this.originalItem,
    required this.targetLanguageCode,
    required this.isTranslationSupported,
    this.translatedContent,
    this.isTranslationActive = false,
    this.isTranslating = false,
    this.error,
    this.notice,
  });

  factory ApodArticleTranslationState.initial({
    required ApodItem originalItem,
    required String targetLanguageCode,
    required bool isTranslationSupported,
  }) {
    return ApodArticleTranslationState(
      originalItem: originalItem,
      targetLanguageCode: targetLanguageCode,
      isTranslationSupported: isTranslationSupported,
    );
  }

  final ApodItem originalItem;
  final ApodArticleTranslation? translatedContent;
  final String targetLanguageCode;
  final bool isTranslationSupported;
  final bool isTranslationActive;
  final bool isTranslating;
  final AppException? error;
  final ApodArticleTranslationNotice? notice;

  String get displayedTitle {
    if (!isTranslationActive || translatedContent == null) {
      return originalItem.title;
    }

    return translatedContent!.title;
  }

  String get displayedExplanation {
    if (!isTranslationActive || translatedContent == null) {
      return originalItem.explanation;
    }

    return translatedContent!.explanation;
  }

  ApodArticleTranslationState copyWith({
    ApodItem? originalItem,
    ApodArticleTranslation? translatedContent,
    String? targetLanguageCode,
    bool? isTranslationSupported,
    bool? isTranslationActive,
    bool? isTranslating,
    AppException? error,
    ApodArticleTranslationNotice? notice,
    bool clearTranslatedContent = false,
    bool clearError = false,
    bool clearNotice = false,
  }) {
    return ApodArticleTranslationState(
      originalItem: originalItem ?? this.originalItem,
      translatedContent: clearTranslatedContent
          ? null
          : (translatedContent ?? this.translatedContent),
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      isTranslationSupported:
          isTranslationSupported ?? this.isTranslationSupported,
      isTranslationActive: isTranslationActive ?? this.isTranslationActive,
      isTranslating: isTranslating ?? this.isTranslating,
      error: clearError ? null : (error ?? this.error),
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}

class ApodArticleTranslationNotice {
  ApodArticleTranslationNotice._({
    required this.message,
    required this.isError,
    required this.id,
  });

  factory ApodArticleTranslationNotice.info(String message) {
    return ApodArticleTranslationNotice._(
      message: message,
      isError: false,
      id: DateTime.now().microsecondsSinceEpoch,
    );
  }

  factory ApodArticleTranslationNotice.error(String message) {
    return ApodArticleTranslationNotice._(
      message: message,
      isError: true,
      id: DateTime.now().microsecondsSinceEpoch,
    );
  }

  final String message;
  final bool isError;
  final int id;
}
