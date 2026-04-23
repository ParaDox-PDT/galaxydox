import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/translation/translation_language_options.dart';
import '../../data/settings_local_data_source.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  return SettingsLocalDataSource();
});

final apodTranslationLanguageProvider =
    NotifierProvider<
      ApodTranslationLanguageController,
      TranslationLanguageOption
    >(ApodTranslationLanguageController.new);

final apodTranslationLanguageCodeProvider = Provider<String>((ref) {
  return ref.watch(apodTranslationLanguageProvider).code;
});

class ApodTranslationLanguageController
    extends Notifier<TranslationLanguageOption> {
  late SettingsLocalDataSource _dataSource;

  @override
  TranslationLanguageOption build() {
    _dataSource = ref.watch(settingsLocalDataSourceProvider);
    return _dataSource.readApodTranslationLanguage();
  }

  Future<void> setLanguage(TranslationLanguageOption option) async {
    if (state.code == option.code) {
      return;
    }

    await _dataSource.saveApodTranslationLanguageCode(option.code);
    state = option;
  }
}
