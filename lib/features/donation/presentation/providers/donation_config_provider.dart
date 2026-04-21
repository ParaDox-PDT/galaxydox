import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/donation_config.dart';
import '../../data/donation_local_data_source.dart';
import '../../data/donation_remote_config_service.dart';

final donationLocalDataSourceProvider = Provider<DonationLocalDataSource>((
  ref,
) {
  return DonationLocalDataSource();
});

final donationRemoteConfigServiceProvider =
    Provider<DonationRemoteConfigService>((ref) {
      return DonationRemoteConfigService(FirebaseRemoteConfig.instance);
    });

class DonationConfigNotifier extends Notifier<DonationConfig> {
  late DonationLocalDataSource _localDataSource;
  late DonationRemoteConfigService _remoteConfigService;

  @override
  DonationConfig build() {
    _localDataSource = ref.read(donationLocalDataSourceProvider);
    _remoteConfigService = ref.read(donationRemoteConfigServiceProvider);
    return _localDataSource.read();
  }

  Future<void> refresh() async {
    try {
      final config = await _remoteConfigService.fetchDonationConfig();
      await _localDataSource.save(config);
      state = config;
    } catch (_) {
      state = _localDataSource.read();
    }
  }
}

final donationConfigProvider =
    NotifierProvider<DonationConfigNotifier, DonationConfig>(
      DonationConfigNotifier.new,
    );
