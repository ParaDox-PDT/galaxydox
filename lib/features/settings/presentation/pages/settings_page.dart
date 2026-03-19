import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/space_scaffold.dart';

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
                  'Configuration is centralized from day one so API credentials and service endpoints can change without touching feature code.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FrostedPanel(
                  child: Column(
                    children: [
                      _SettingRow(
                        label: 'NASA API key source',
                        value: AppConfig.apiKeySourceLabel,
                      ),
                      const Divider(),
                      const _SettingRow(
                        label: 'Core NASA API',
                        value: AppConfig.nasaApiBaseUrl,
                      ),
                      const Divider(),
                      const _SettingRow(
                        label: 'NASA media search API',
                        value: AppConfig.nasaMediaBaseUrl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FrostedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next additions', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(
                        'Favorites, offline feedback, notification preferences, and theme accents will expand from this screen in the next iteration.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.goNamed(AppRoutes.homeName),
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
