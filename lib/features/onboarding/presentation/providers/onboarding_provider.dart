import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/onboarding_local_data_source.dart';

final _onboardingDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  return OnboardingLocalDataSource();
});

/// True if the user has already completed onboarding. Read synchronously from
/// the already-open Hive box during splash navigation.
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.read(_onboardingDataSourceProvider).hasCompletedOnboarding;
});

/// Holds the currently selected orbit route name (null = nothing chosen yet).
class OnboardingNotifier extends Notifier<String?> {
  late OnboardingLocalDataSource _dataSource;

  @override
  String? build() {
    _dataSource = ref.read(_onboardingDataSourceProvider);
    return null;
  }

  void selectOrbit(String routeName) => state = routeName;

  Future<void> complete() async {
    await _dataSource.completeOnboarding(preferredRoute: state);
  }

  Future<void> skip() async {
    await _dataSource.completeOnboarding();
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, String?>(() => OnboardingNotifier());
