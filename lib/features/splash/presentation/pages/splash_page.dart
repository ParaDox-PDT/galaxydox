import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/donation/presentation/providers/donation_config_provider.dart';
import '../../../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/space_scaffold.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      Future<void>.delayed(AppConstants.splashDuration),
      ref.read(donationConfigProvider.notifier).refresh(),
    ]);

    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final hasCompleted = ref.read(hasCompletedOnboardingProvider);
    if (hasCompleted) {
      context.goNamed(AppRoutes.homeName);
    } else {
      context.goNamed(AppRoutes.onboardingName);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SpaceScaffold(
      body:
          Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.pagePadding),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: FrostedPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 104,
                            height: 104,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/galaxydox.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppConstants.appName,
                            style: theme.textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppConstants.appTagline,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: const LinearProgressIndicator(
                              minHeight: 6,
                              backgroundColor: AppColors.surface,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 650.ms)
              .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1))
              .slideY(begin: 0.06, end: 0),
    );
  }
}
