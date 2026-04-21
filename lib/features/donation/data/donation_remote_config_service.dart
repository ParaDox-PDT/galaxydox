import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'donation_config.dart';

class DonationRemoteConfigService {
  DonationRemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  Future<DonationConfig> fetchDonationConfig() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _remoteConfig.setDefaults(const {
      'donation_enabled': false,
      'donation_card_number': '',
      'donation_link': '',
      'donation_link_enabled': false,
    });

    await _remoteConfig.fetchAndActivate();

    return DonationConfig(
      isEnabled: _remoteConfig.getBool('donation_enabled'),
      cardNumber: _remoteConfig.getString('donation_card_number').trim(),
      link: _remoteConfig.getString('donation_link').trim(),
      isLinkEnabled: _remoteConfig.getBool('donation_link_enabled'),
    );
  }
}
