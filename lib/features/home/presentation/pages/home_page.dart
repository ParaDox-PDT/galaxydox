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
        color: AppColors.primaryStrong,
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
                      42,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TopBar()
                            .animate()
                            .fadeIn(duration: 420.ms)
                            .slideY(begin: -0.06, end: 0),
                        const SizedBox(height: 22),
                        const _EditorialLead()
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 480.ms)
                            .slideY(begin: 0.04, end: 0),
                        const SizedBox(height: 26),
                        HeroFeatureCard(hero: preview.hero)
                            .animate()
                            .fadeIn(delay: 140.ms, duration: 560.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: AppConstants.sectionGap),
                        const _OrbitSummary()
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 500.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: AppConstants.sectionGap),
                        SectionHeading(
                              eyebrow: 'Mission lanes',
                              title: 'Explore the archive in focused modes',
                              subtitle:
                                  'Each lane is designed to feel editorial and calm, whether you are reading the story of the day or scanning dense telemetry.',
                              actionLabel: 'Preferences',
                              onActionPressed: () =>
                                  context.goNamed(AppRoutes.settingsName),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 500.ms)
                            .slideY(begin: 0.05, end: 0),
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
                                                    360 + (index * 90),
                                              ),
                                              duration: 520.ms,
                                            )
                                            .slideY(begin: 0.06, end: 0),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.sectionGap),
                        const _DiscoveryDeck()
                            .animate()
                            .fadeIn(delay: 680.ms, duration: 520.ms)
                            .slideY(begin: 0.06, end: 0),
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.tertiary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStrong.withValues(alpha: 0.28),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.backgroundDeep,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Editorial-grade NASA explorer',
                    style: theme.textTheme.bodyMedium,
                  ),
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
      width: 56,
      height: 56,
      child: FrostedPanel(
        padding: EdgeInsets.zero,
        radius: 18,
        child: IconButton(onPressed: onPressed, icon: Icon(icon)),
      ),
    );
  }
}

class _EditorialLead extends StatelessWidget {
  const _EditorialLead();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;

        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tonight\'s orbit',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Curated for discovery, not clutter.',
              style: theme.textTheme.headlineLarge,
            ),
          ],
        );

        final support = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'GalaxyDox is shaping up as a calm, cinematic way to browse NASA stories, imagery, and mission data from one elegant mobile surface.',
            style: theme.textTheme.bodyLarge,
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [intro, const SizedBox(height: 14), support],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(flex: 3, child: intro),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: support),
          ],
        );
      },
    );
  }
}

class _OrbitSummary extends StatelessWidget {
  const _OrbitSummary();

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final items = const [
            _SummaryCard(
              title: 'Daily story',
              body: 'APOD becomes the emotional anchor of the app.',
            ),
            _SummaryCard(
              title: 'Mission gallery',
              body: 'Rover photography is built to reward long scrolling.',
            ),
            _SummaryCard(
              title: 'Deep scan',
              body: 'Asteroid data stays readable even when dense.',
            ),
          ];

          if (compact) {
            return Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  items[index],
                  if (index != items.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                Expanded(child: items[index]),
                if (index != items.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DiscoveryDeck extends StatelessWidget {
  const _DiscoveryDeck();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 920;

          final lead = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Built for repeat discovery',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'The strongest NASA apps make information feel inviting. This foundation is leaning into bold imagery, quiet data density, and motion that supports the content instead of distracting from it.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );

          final bullets = Column(
            children: const [
              _DiscoveryBullet(
                title: 'Story-first',
                body: 'Big imagery and clean reading rhythm.',
              ),
              SizedBox(height: 12),
              _DiscoveryBullet(
                title: 'Archive-friendly',
                body: 'Layouts built for browsing at depth.',
              ),
              SizedBox(height: 12),
              _DiscoveryBullet(
                title: 'Data-aware',
                body: 'Telemetry can be dense without becoming noisy.',
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [lead, const SizedBox(height: 20), bullets],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: lead),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: bullets),
            ],
          );
        },
      ),
    );
  }
}

class _DiscoveryBullet extends StatelessWidget {
  const _DiscoveryBullet({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
