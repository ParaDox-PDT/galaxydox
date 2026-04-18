import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/ambient_space_background.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../providers/onboarding_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Orbit options (used by step 3 and step 4 + bottom nav)
// ─────────────────────────────────────────────────────────────────────────────

class _OrbitOption {
  const _OrbitOption({
    required this.label,
    required this.routeName,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String routeName;
  final IconData icon;
  final Color accent;
}

const _orbitOptions = <_OrbitOption>[
  _OrbitOption(
    label: 'Home',
    routeName: AppRoutes.homeName,
    icon: Icons.home_rounded,
    accent: AppColors.primary,
  ),
  _OrbitOption(
    label: 'APOD',
    routeName: AppRoutes.apodName,
    icon: Icons.auto_awesome_rounded,
    accent: AppColors.primary,
  ),
  _OrbitOption(
    label: '3D Planets',
    routeName: AppRoutes.planets3dName,
    icon: Icons.view_in_ar_rounded,
    accent: Color(0xFF9D8DFF),
  ),
  _OrbitOption(
    label: 'EPIC Earth',
    routeName: AppRoutes.epicEarthName,
    icon: Icons.public_rounded,
    accent: AppColors.tertiary,
  ),
  _OrbitOption(
    label: 'NEO Watch',
    routeName: AppRoutes.neoName,
    icon: Icons.track_changes_rounded,
    accent: AppColors.warning,
  ),
  _OrbitOption(
    label: 'Search Archive',
    routeName: AppRoutes.searchName,
    icon: Icons.grid_view_rounded,
    accent: AppColors.secondary,
  ),
];

_OrbitOption? _findOrbit(String? routeName) {
  if (routeName == null) return null;
  try {
    return _orbitOptions.firstWhere((o) => o.routeName == routeName);
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main page
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _currentStep = 0;
  static const _totalSteps = 4;

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  Future<void> _complete({bool forceHome = false}) async {
    await ref.read(onboardingNotifierProvider.notifier).complete();
    if (!mounted) return;

    if (forceHome) {
      context.goNamed(AppRoutes.homeName);
      return;
    }

    final preferred = ref.read(onboardingNotifierProvider);
    if (preferred == null || preferred == AppRoutes.homeName) {
      context.goNamed(AppRoutes.homeName);
    } else {
      // Set home as root, then push the selected screen on top so back works.
      context.goNamed(AppRoutes.homeName);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushNamed(preferred);
      });
    }
  }

  Future<void> _skip() async {
    await ref.read(onboardingNotifierProvider.notifier).skip();
    if (!mounted) return;
    context.goNamed(AppRoutes.homeName);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOrbit = ref.watch(onboardingNotifierProvider);
    final isLastStep = _currentStep == _totalSteps - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientSpaceBackground(),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.screenVeil),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onSkip: _skip,
                  showSkip: !isLastStep,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppConstants.motionSlow,
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.034),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                    child: [
                      const _BrandIntroStep(key: ValueKey(0)),
                      const _DiscoveryLanesStep(key: ValueKey(1)),
                      _ChooseOrbitStep(
                        key: const ValueKey(2),
                        selectedOrbit: selectedOrbit,
                        onOrbitSelected: (route) => ref
                            .read(onboardingNotifierProvider.notifier)
                            .selectOrbit(route),
                      ),
                      _ReadyStep(
                        key: const ValueKey(3),
                        selectedOrbit: selectedOrbit,
                      ),
                    ][_currentStep],
                  ),
                ),
                _BottomNav(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  selectedOrbit: selectedOrbit,
                  isLastStep: isLastStep,
                  onNext: _next,
                  onComplete: () => _complete(),
                  onCompleteToHome: () => _complete(forceHome: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip, required this.showSkip});

  final VoidCallback onSkip;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        12,
        AppConstants.pagePadding,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: ClipOval(
              child: Image.asset(
                'assets/images/galaxydox.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: showSkip ? 1 : 0,
            duration: AppConstants.motionMedium,
            child: TextButton(
              onPressed: showSkip ? onSkip : null,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav — step dots + CTA buttons
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.selectedOrbit,
    required this.isLastStep,
    required this.onNext,
    required this.onComplete,
    required this.onCompleteToHome,
  });

  final int currentStep;
  final int totalSteps;
  final String? selectedOrbit;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onComplete;
  final VoidCallback onCompleteToHome;

  bool get _showSecondary =>
      isLastStep &&
      selectedOrbit != null &&
      selectedOrbit != AppRoutes.homeName;

  String get _primaryLabel {
    if (!isLastStep) return 'Continue';
    final opt = _findOrbit(selectedOrbit);
    if (opt == null) return 'Enter GalaxyDox';
    return 'Start with ${opt.label}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        16,
        AppConstants.pagePadding,
        24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (i) {
              final isActive = i == currentStep;
              return AnimatedContainer(
                duration: AppConstants.motionMedium,
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.outlineSoft,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLastStep ? onComplete : onNext,
              child: Text(_primaryLabel),
            ),
          ),
          if (_showSecondary) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCompleteToHome,
                child: const Text('Go to Home'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Brand intro
// ─────────────────────────────────────────────────────────────────────────────

class _BrandIntroStep extends StatelessWidget {
  const _BrandIntroStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryStrong.withValues(alpha: 0.28),
                        AppColors.primaryStrong.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 84,
                  height: 84,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/galaxydox.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FrostedPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A premium field guide\nto NASA\'s universe.',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Curated imagery, real mission data, and cinematic editorial '
                  'experiences—designed for those who look up.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Tag('NASA Open APIs'),
                    _Tag('Editorial discovery'),
                    _Tag('Live mission data'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Discovery lanes
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryLanesStep extends StatelessWidget {
  const _DiscoveryLanesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            'Three lanes\nof discovery.',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Each built for a different kind of exploration.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          _LaneCard(
            icon: Icons.auto_awesome_rounded,
            accent: AppColors.primary,
            label: 'Daily Story',
            subtitle: 'APOD',
            description:
                "Today's astronomy image, expanded into a full-screen narrative.",
          ),
          const SizedBox(height: 12),
          _LaneCard(
            icon: Icons.view_in_ar_rounded,
            accent: const Color(0xFF9D8DFF),
            label: 'Immersive Worlds',
            subtitle: '3D Planets · EPIC Earth',
            description:
                'Interactive planetary models and Earth from a million miles out.',
          ),
          const SizedBox(height: 12),
          _LaneCard(
            icon: Icons.track_changes_rounded,
            accent: AppColors.warning,
            label: 'Deep Scan',
            subtitle: 'NEO · Search Archive',
            description:
                'Asteroid intelligence and the full NASA media vault, always accessible.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LaneCard extends StatelessWidget {
  const _LaneCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.subtitle,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String subtitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: theme.textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Choose your orbit
// ─────────────────────────────────────────────────────────────────────────────

class _ChooseOrbitStep extends StatelessWidget {
  const _ChooseOrbitStep({
    super.key,
    required this.selectedOrbit,
    required this.onOrbitSelected,
  });

  final String? selectedOrbit;
  final ValueChanged<String> onOrbitSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            'Where would you\nlike to begin?',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your first destination. You can explore everything else after.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: _orbitOptions
                .map(
                  (opt) => _OrbitCard(
                    option: opt,
                    isSelected: selectedOrbit == opt.routeName,
                    onTap: () => onOrbitSelected(opt.routeName),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OrbitCard extends StatelessWidget {
  const _OrbitCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _OrbitOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.motionFast,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? option.accent.withValues(alpha: 0.13)
              : AppColors.surfaceElevated.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected
                ? option.accent.withValues(alpha: 0.6)
                : AppColors.outlineSoft,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  option.icon,
                  color: isSelected ? option.accent : AppColors.textSecondary,
                  size: 22,
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: option.accent,
                    size: 18,
                  ),
              ],
            ),
            Text(
              option.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Ready
// ─────────────────────────────────────────────────────────────────────────────

class _ReadyStep extends StatelessWidget {
  const _ReadyStep({super.key, required this.selectedOrbit});

  final String? selectedOrbit;

  String get _headline {
    final opt = _findOrbit(selectedOrbit);
    if (opt == null) return 'Ready to explore.';
    return 'Ready.\nStart with ${opt.label}.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opt = _findOrbit(selectedOrbit);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(
            child: opt != null
                ? Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: opt.accent.withValues(alpha: 0.14),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                      border:
                          Border.all(color: opt.accent.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: opt.accent.withValues(alpha: 0.22),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: Icon(opt.icon, color: opt.accent, size: 34),
                  )
                : SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/galaxydox.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          FrostedPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _headline,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  'Your GalaxyDox mission begins now. '
                  'Every orbit is one tap away.',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
      ),
    );
  }
}
