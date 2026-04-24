import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/translation/text_translation_service.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../../../settings/presentation/providers/translation_language_settings_controller.dart';
import '../../domain/entities/nasa_media_item.dart';

final nasaMediaTranslationControllerProvider = NotifierProvider.autoDispose
    .family<
      NasaMediaTranslationController,
      NasaMediaTranslationState,
      NasaMediaTranslationTarget
    >(NasaMediaTranslationController.new);

class NasaMediaTranslationController
    extends Notifier<NasaMediaTranslationState> {
  NasaMediaTranslationController(this._target);

  final NasaMediaTranslationTarget _target;
  late final TextTranslationService _translationService;
  int _requestVersion = 0;

  @override
  NasaMediaTranslationState build() {
    _translationService = ref.watch(textTranslationServiceProvider);
    final targetLanguage = ref.watch(apodTranslationLanguageProvider);
    final previousState = stateOrNull;

    if (previousState != null) {
      final translation = previousState.translatedContent;
      final hasCurrentTranslation =
          translation != null &&
          translation.targetLanguageCode == targetLanguage.code;

      return previousState.copyWith(
        targetLanguageCode: targetLanguage.code,
        translatedContent: hasCurrentTranslation ? translation : null,
        clearTranslatedContent: !hasCurrentTranslation,
        isTranslationActive: hasCurrentTranslation
            ? previousState.isTranslationActive
            : false,
        isTranslating: false,
        clearError: true,
        clearNotice: true,
      );
    }

    return NasaMediaTranslationState.initial(
      target: _target,
      targetLanguageCode: targetLanguage.code,
    );
  }

  Future<void> translate() async {
    if (state.isTranslating) {
      return;
    }

    final targetLanguage =
        TranslationLanguageOptions.fromCode(state.targetLanguageCode) ??
        TranslationLanguageOptions.english;
    if (targetLanguage.isEnglish) {
      state = state.copyWith(
        notice: NasaMediaTranslationNotice.info(
          'Choose a language other than English to translate this NASA result.',
        ),
        clearError: true,
      );
      return;
    }

    final currentTranslation = state.translatedContent;
    if (currentTranslation != null &&
        currentTranslation.targetLanguageCode == targetLanguage.code) {
      if (state.isTranslationActive) {
        return;
      }

      state = state.copyWith(
        isTranslationActive: true,
        clearError: true,
        notice: NasaMediaTranslationNotice.info(
          'Translated to ${targetLanguage.label}.',
        ),
      );
      return;
    }

    final requestVersion = ++_requestVersion;
    state = state.copyWith(
      isTranslating: true,
      isTranslationActive: false,
      clearError: true,
      clearNotice: true,
      clearTranslatedContent:
          currentTranslation?.targetLanguageCode != targetLanguage.code,
    );

    try {
      final translatedTitle = await _translationService.translateText(
        text: _target.title,
        sourceLanguageCode: 'en',
        targetLanguageCode: targetLanguage.code,
      );
      final translatedDescription = await _translationService.translateText(
        text: _target.description,
        sourceLanguageCode: 'en',
        targetLanguageCode: targetLanguage.code,
      );

      if (!ref.mounted || requestVersion != _requestVersion) {
        return;
      }

      state = state.copyWith(
        translatedContent: NasaMediaTextTranslation(
          targetLanguageCode: targetLanguage.code,
          title: translatedTitle,
          description: translatedDescription,
        ),
        isTranslationActive: true,
        isTranslating: false,
        clearError: true,
        notice: NasaMediaTranslationNotice.info(
          'Translated to ${targetLanguage.label}.',
        ),
      );
    } on AppException catch (exception) {
      _handleTranslationFailure(exception, requestVersion);
    } catch (error) {
      _handleTranslationFailure(
        AppException(
          type: AppExceptionType.network,
          message:
              "Couldn't translate this NASA result. Check your internet connection and try again.",
          cause: error,
        ),
        requestVersion,
      );
    }
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

  void _handleTranslationFailure(AppException exception, int requestVersion) {
    if (!ref.mounted || requestVersion != _requestVersion) {
      return;
    }

    state = state.copyWith(
      isTranslating: false,
      isTranslationActive: false,
      error: exception,
      notice: NasaMediaTranslationNotice.error(_friendlyMessage(exception)),
    );
  }

  String _friendlyMessage(AppException exception) {
    if (exception.message ==
        'Internet connection is required for translation.') {
      return exception.message;
    }

    if (exception.type == AppExceptionType.timeout) {
      return 'Translation took too long. Check your internet connection and try again.';
    }

    if (exception.message ==
        'The selected translation language is not supported.') {
      return exception.message;
    }

    return "Couldn't translate this NASA result. Check your internet connection and try again.";
  }
}

class NasaMediaTranslationTarget {
  const NasaMediaTranslationTarget({
    required this.nasaId,
    required this.title,
    required this.description,
  });

  factory NasaMediaTranslationTarget.fromItem(NasaMediaItem item) {
    return NasaMediaTranslationTarget(
      nasaId: item.nasaId,
      title: item.title,
      description: item.description,
    );
  }

  final String nasaId;
  final String title;
  final String description;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NasaMediaTranslationTarget &&
            other.nasaId == nasaId &&
            other.title == title &&
            other.description == description;
  }

  @override
  int get hashCode => Object.hash(nasaId, title, description);
}

class NasaMediaTextTranslation {
  const NasaMediaTextTranslation({
    required this.targetLanguageCode,
    required this.title,
    required this.description,
  });

  final String targetLanguageCode;
  final String title;
  final String description;
}

class NasaMediaTranslationState {
  const NasaMediaTranslationState({
    required this.target,
    required this.targetLanguageCode,
    this.translatedContent,
    this.isTranslationActive = false,
    this.isTranslating = false,
    this.error,
    this.notice,
  });

  factory NasaMediaTranslationState.initial({
    required NasaMediaTranslationTarget target,
    required String targetLanguageCode,
  }) {
    return NasaMediaTranslationState(
      target: target,
      targetLanguageCode: targetLanguageCode,
    );
  }

  final NasaMediaTranslationTarget target;
  final String targetLanguageCode;
  final NasaMediaTextTranslation? translatedContent;
  final bool isTranslationActive;
  final bool isTranslating;
  final AppException? error;
  final NasaMediaTranslationNotice? notice;

  bool get hasCurrentTranslation {
    return translatedContent?.targetLanguageCode == targetLanguageCode;
  }

  String get displayedTitle {
    if (!isTranslationActive || translatedContent == null) {
      return target.title;
    }

    return translatedContent!.title;
  }

  String get displayedDescription {
    if (!isTranslationActive || translatedContent == null) {
      return target.description;
    }

    return translatedContent!.description;
  }

  NasaMediaTranslationState copyWith({
    String? targetLanguageCode,
    NasaMediaTextTranslation? translatedContent,
    bool? isTranslationActive,
    bool? isTranslating,
    AppException? error,
    NasaMediaTranslationNotice? notice,
    bool clearTranslatedContent = false,
    bool clearError = false,
    bool clearNotice = false,
  }) {
    return NasaMediaTranslationState(
      target: target,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      translatedContent: clearTranslatedContent
          ? null
          : (translatedContent ?? this.translatedContent),
      isTranslationActive: isTranslationActive ?? this.isTranslationActive,
      isTranslating: isTranslating ?? this.isTranslating,
      error: clearError ? null : (error ?? this.error),
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}

class NasaMediaTranslationNotice {
  NasaMediaTranslationNotice._({
    required this.message,
    required this.isError,
    required this.id,
  });

  factory NasaMediaTranslationNotice.info(String message) {
    return NasaMediaTranslationNotice._(
      message: message,
      isError: false,
      id: DateTime.now().microsecondsSinceEpoch,
    );
  }

  factory NasaMediaTranslationNotice.error(String message) {
    return NasaMediaTranslationNotice._(
      message: message,
      isError: true,
      id: DateTime.now().microsecondsSinceEpoch,
    );
  }

  final String message;
  final bool isError;
  final int id;
}
