import 'package:hive_flutter/hive_flutter.dart';

import 'donation_config.dart';

class DonationLocalDataSource {
  static const _boxName = 'app_preferences';
  static const _enabledKey = 'donation_enabled';
  static const _cardNumberKey = 'donation_card_number';
  static const _linkKey = 'donation_link';
  static const _linkEnabledKey = 'donation_link_enabled';

  Box get _box => Hive.box(_boxName);

  DonationConfig read() {
    return DonationConfig(
      isEnabled: _box.get(_enabledKey, defaultValue: false) as bool,
      cardNumber: (_box.get(_cardNumberKey, defaultValue: '') as String).trim(),
      link: (_box.get(_linkKey, defaultValue: '') as String).trim(),
      isLinkEnabled: _box.get(_linkEnabledKey, defaultValue: false) as bool,
    );
  }

  Future<void> save(DonationConfig config) async {
    final current = read();

    if (current.isEnabled != config.isEnabled) {
      await _box.put(_enabledKey, config.isEnabled);
    }

    if (current.cardNumber != config.cardNumber) {
      await _box.put(_cardNumberKey, config.cardNumber);
    }

    if (current.link != config.link) {
      await _box.put(_linkKey, config.link);
    }

    if (current.isLinkEnabled != config.isLinkEnabled) {
      await _box.put(_linkEnabledKey, config.isLinkEnabled);
    }
  }
}
