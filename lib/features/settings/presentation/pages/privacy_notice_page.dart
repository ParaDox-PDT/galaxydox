import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/space_scaffold.dart';

class PrivacyNoticePage extends StatelessWidget {
  const PrivacyNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pagePadding,
          12,
          AppConstants.pagePadding,
          42,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
                const SizedBox(height: 20),
                Text('Privacy notice', style: theme.textTheme.displayMedium),
                const SizedBox(height: 12),
                Text(
                  'GalaxyDox is designed to minimize collection where possible. The app focuses on reading NASA content, bookmarking favorites locally, and avoiding ads, social login, or profile accounts.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                const _PrivacySection(
                  title: 'What the app stores',
                  body:
                      'Bookmarks are stored only on your device with shared preferences. The app does not create accounts, collect profile data, or sync bookmarks to developer-controlled servers.',
                ),
                const SizedBox(height: 18),
                const _PrivacySection(
                  title: 'What leaves the device',
                  body:
                      'Search terms and NASA content requests are sent directly to NASA-operated APIs and media hosts so the app can load astronomy images, rover photos, asteroid data, and archive search results. Firebase is also used for app configuration, analytics, crash reporting, Firestore-hosted content, and optional push notification delivery when you grant permission.',
                ),
                const SizedBox(height: 18),
                const _PrivacySection(
                  title: 'What the app does not include',
                  body:
                      'GalaxyDox does not ship with ad networks, social login, or location tracking. Push notifications remain optional and are requested only after onboarding.',
                ),
                const SizedBox(height: 18),
                const _PrivacySection(
                  title: 'Public release note',
                  body:
                      'Store privacy answers should still be reviewed before submission, especially for how NASA may process search requests and network identifiers on its own infrastructure.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
