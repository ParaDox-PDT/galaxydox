import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import 'privacy_notice_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: theme.textTheme.displayMedium),
                const SizedBox(height: 10),
                Text(
                  'GalaxyDox keeps privacy and core app actions easy to reach without clutter.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FrostedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy at a glance',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The app stores bookmarks only on-device, sends NASA search and content requests directly to NASA services, and does not include ads, analytics SDKs, or account sign-in.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const PrivacyNoticePage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.privacy_tip_outlined),
                            label: const Text('Privacy notice'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.pushNamed(AppRoutes.bookmarksName),
                            icon: const Icon(Icons.bookmarks_rounded),
                            label: const Text('Bookmarks'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).maybePop();
                            return;
                          }

                          context.goNamed(AppRoutes.homeName);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Return to Home'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
