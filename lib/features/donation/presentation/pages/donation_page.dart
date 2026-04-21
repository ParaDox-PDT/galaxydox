import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/donation_config.dart';
import '../providers/donation_config_provider.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/space_scaffold.dart';

class DonationPage extends ConsumerWidget {
  const DonationPage({super.key});

  Future<void> _copyCardNumber(BuildContext context, String cardNumber) async {
    await Clipboard.setData(ClipboardData(text: cardNumber));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Card number copied.')));
  }

  Future<void> _openPaymentLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationConfig = ref.watch(donationConfigProvider);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Donation',
                  subtitle: 'If you want, you can support the project.',
                  actions: [],
                ),
                const SizedBox(height: 20),
                FrostedPanel(
                  child: _DonationContent(
                    config: donationConfig,
                    onCopyCardNumber: (cardNumber) =>
                        _copyCardNumber(context, cardNumber),
                    onOpenPaymentLink: (url) => _openPaymentLink(context, url),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonationContent extends StatelessWidget {
  const _DonationContent({
    required this.config,
    required this.onCopyCardNumber,
    required this.onOpenPaymentLink,
  });

  final DonationConfig config;
  final ValueChanged<String> onCopyCardNumber;
  final ValueChanged<String> onOpenPaymentLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!config.isEnabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support', style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          Text(
            'Donations are currently unavailable.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support', style: theme.textTheme.titleLarge),
        if (config.hasCardNumber) ...[
          const SizedBox(height: 18),
          _DonationActionCard(
            title: 'Card number',
            value: config.cardNumber,
            leadingIcon: Icons.copy_rounded,
            trailingIcon: Icons.touch_app_rounded,
            onTap: () => onCopyCardNumber(config.cardNumber),
          ),
          const SizedBox(height: 10),
          Text('For users in Uzbekistan', style: theme.textTheme.bodyMedium),
        ],
        if (config.hasPaymentLink) ...[
          if (config.hasCardNumber) const SizedBox(height: 14),
          _DonationActionCard(
            title: 'Payment link',
            value: config.link,
            leadingIcon: Icons.language_rounded,
            trailingIcon: Icons.open_in_new_rounded,
            onTap: () => onOpenPaymentLink(config.link),
            ellipsizeValue: true,
          ),
          const SizedBox(height: 10),
          Text('For online payments', style: theme.textTheme.bodyMedium),
        ],
        if (config.hasCardNumber) ...[
          const SizedBox(height: 14),
          Text(
            'Tap once to copy the card number.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (!config.hasCardNumber && !config.hasPaymentLink) ...[
          const SizedBox(height: 14),
          Text(
            'No donation options are available right now.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }
}

class _DonationActionCard extends StatelessWidget {
  const _DonationActionCard({
    required this.title,
    required this.value,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onTap,
    this.ellipsizeValue = false,
  });

  final String title;
  final String value;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final bool ellipsizeValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryStrong.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(leadingIcon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    if (ellipsizeValue)
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: theme.textTheme.titleLarge?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(trailingIcon),
            ],
          ),
        ),
      ),
    );
  }
}
