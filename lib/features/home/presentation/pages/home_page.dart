import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../providers/home_preview_provider.dart';
import '../widgets/hero_feature_card.dart';
import '../widgets/home_feature_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(homePreviewProvider);
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(homePreviewProvider);

    return SpaceScaffold(
      bottomSafeArea: true,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceStrong,
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pagePadding,
                      12,
                      AppConstants.pagePadding,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TopBar()
                            .animate()
                            .fadeIn(duration: 450.ms)
                            .slideY(begin: -0.08, end: 0),
                        const SizedBox(height: 28),
                        HeroFeatureCard(hero: preview.hero)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 550.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 32),
                        SectionHeading(
                              eyebrow: 'Explore',
                              title: 'Choose a mission lane',
                              subtitle:
                                  'Every destination is designed as a focused content experience, from the day\'s headline image to dense asteroid telemetry.',
                              actionLabel: 'Preferences',
                              onActionPressed: () =>
                                  context.goNamed(AppRoutes.settingsName),
                            )
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 500.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 980;
                            final spacing = 20.0;
                            final width = isWide
                                ? (constraints.maxWidth - spacing) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (
                                  var index = 0;
                                  index < preview.sections.length;
                                  index++
                                )
                                  SizedBox(
                                    width: width,
                                    child:
                                        HomeFeatureCard(
                                              feature: preview.sections[index],
                                            )
                                            .animate()
                                            .fadeIn(
                                              delay: Duration(
                                                milliseconds:
                                                    320 + (index * 90),
                                              ),
                                              duration: 520.ms,
                                            )
                                            .slideY(begin: 0.08, end: 0),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        const _MissionDeck()
                            .animate()
                            .fadeIn(delay: 620.ms, duration: 520.ms)
                            .slideY(begin: 0.08, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.tertiary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Explore the cosmos', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _PanelIconButton(
          icon: Icons.travel_explore_rounded,
          onPressed: () => context.goNamed(AppRoutes.searchName),
        ),
        const SizedBox(width: 12),
        _PanelIconButton(
          icon: Icons.tune_rounded,
          onPressed: () => context.goNamed(AppRoutes.settingsName),
        ),
      ],
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: FrostedPanel(
        padding: EdgeInsets.zero,
        radius: 18,
        child: IconButton(onPressed: onPressed, icon: Icon(icon)),
      ),
    );
  }
}

class _MissionDeck extends StatelessWidget {
  const _MissionDeck();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Production foundation ready',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'This first slice establishes the architecture, premium theme, routing, centralized NASA config, and the launch-ready home experience. Next we wire each feature to live NASA data through repositories and use cases.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FlightChip(label: 'Riverpod state'),
              _FlightChip(label: 'GoRouter routes'),
              _FlightChip(label: 'Dio API shell'),
              _FlightChip(label: 'NASA key centralized'),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [textBlock, const SizedBox(height: 18), chips],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: textBlock),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: chips),
            ],
          );
        },
      ),
    );
  }
}

class _FlightChip extends StatelessWidget {
  const _FlightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Text(label),
    );
  }
}
