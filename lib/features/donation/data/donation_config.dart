class DonationConfig {
  const DonationConfig({
    required this.isEnabled,
    required this.cardNumber,
    required this.link,
    required this.isLinkEnabled,
  });

  const DonationConfig.defaults()
    : isEnabled = false,
      cardNumber = '',
      link = '',
      isLinkEnabled = false;

  final bool isEnabled;
  final String cardNumber;
  final String link;
  final bool isLinkEnabled;

  bool get hasCardNumber => cardNumber.trim().isNotEmpty;
  bool get hasPaymentLink => isLinkEnabled && link.trim().isNotEmpty;

  DonationConfig copyWith({
    bool? isEnabled,
    String? cardNumber,
    String? link,
    bool? isLinkEnabled,
  }) {
    return DonationConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      cardNumber: cardNumber ?? this.cardNumber,
      link: link ?? this.link,
      isLinkEnabled: isLinkEnabled ?? this.isLinkEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DonationConfig &&
        other.isEnabled == isEnabled &&
        other.cardNumber == cardNumber &&
        other.link == link &&
        other.isLinkEnabled == isLinkEnabled;
  }

  @override
  int get hashCode => Object.hash(isEnabled, cardNumber, link, isLinkEnabled);
}
