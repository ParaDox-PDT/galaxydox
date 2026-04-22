import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../donation/presentation/providers/donation_config_provider.dart';
import '../../../notifications/presentation/providers/notification_lifecycle_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
// import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../providers/home_preview_provider.dart';
// import '../widgets/hero_feature_card.dart';
import '../widgets/home_feature_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _didHandleNotificationPermissionFlow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleNotificationPermissionFlow();
    });
  }

  Future<void> _handleNotificationPermissionFlow() async {
    if (_didHandleNotificationPermissionFlow || !mounted) return;
    _didHandleNotificationPermissionFlow = true;

    final controller = ref.read(notificationLifecycleControllerProvider);
    await controller.initialize(
      router: ref.read(appRouterProvider),
      navigatorKey: ref.read(rootNavigatorKeyProvider),
    );

    if (!controller.shouldSuggestPermissionPrompt() || !mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;

    final shouldRequestPermission =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Stay in the loop?'),
              content: const Text(
                'Would you like to stay up to date with GalaxyDox news, new wallpapers, and app updates? Turn on notifications so you never miss what is new.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Not now'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Turn on notifications'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (shouldRequestPermission) {
      await controller.requestPermissionFromSuggestion();
      return;
    }

    await controller.skipPermissionPromptSuggestion();
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(homePreviewProvider);
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(homePreviewProvider);
    final donationConfig = ref.watch(donationConfigProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = viewportWidth < 640
        ? 16.0
        : AppConstants.pagePadding;

    return SpaceScaffold(
      bottomSafeArea: true,
      body: PremiumRefreshIndicator(
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
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 42).copyWith(
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                              showDonationAction: donationConfig.isEnabled,
                              unreadNotificationCount: unreadCount,
                            )
                            .animate()
                            .fadeIn(duration: 420.ms)
                            .slideY(begin: -0.06, end: 0),
                        // Temporarily hidden because this repeated intro feels
                        // more like onboarding than a useful home visit.
                        /*
                        const SizedBox(height: 22),
                        const _EditorialLead()
                            .animate()
                            .fadeIn(delay: 120.ms, duration: 480.ms)
                            .slideY(begin: 0.04, end: 0),
                        const SizedBox(height: 26),
                        HeroFeatureCard(hero: preview.hero)
                            .animate()
                            .fadeIn(delay: 180.ms, duration: 560.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: AppConstants.sectionGap),
                        const _OrbitSummary()
                            .animate()
                            .fadeIn(delay: 260.ms, duration: 500.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: AppConstants.sectionGap),
                        SectionHeading(
                              eyebrow: 'Mission lanes',
                              title: 'Explore the archive in focused modes',
                              subtitle:
                                  'Each lane is designed to feel editorial and calm, whether you are reading the story of the day or scanning dense telemetry.',
                              actionLabel: 'Preferences',
                              onActionPressed: () =>
                                  context.pushNamed(AppRoutes.settingsName),
                            )
                            .animate()
                            .fadeIn(delay: 340.ms, duration: 500.ms)
                            .slideY(begin: 0.05, end: 0),
                        const SizedBox(height: 20),
                        */
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final spacing = constraints.maxWidth < 640
                                ? 16.0
                                : 20.0;
                            final columns = constraints.maxWidth >= 940 ? 2 : 1;
                            final width = columns == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth - spacing) / 2;

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
                                                    400 + (index * 90),
                                              ),
                                              duration: 520.ms,
                                            )
                                            .slideY(begin: 0.06, end: 0),
                                  ),
                              ],
                            );
                          },
                        ),
                        // Temporarily hidden to keep the home screen focused on
                        // the main feature cards instead of repeat intro copy.
                        /*
                        const SizedBox(height: AppConstants.sectionGap),
                        const _DiscoveryDeck()
                            .animate()
                            .fadeIn(delay: 720.ms, duration: 520.ms)
                            .slideY(begin: 0.06, end: 0),
                        */
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
  const _TopBar({
    required this.showDonationAction,
    required this.unreadNotificationCount,
  });

  final bool showDonationAction;
  final int unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final isNarrow = constraints.maxWidth < 420;
        final iconButtonSize = constraints.maxWidth < 520 ? 52.0 : 56.0;

        final notificationAction = _PanelIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          size: iconButtonSize,
          badgeCount: unreadNotificationCount,
          onPressed: () => context.pushNamed(AppRoutes.notificationsName),
        );

        final brand = Row(
          children: [
            Container(
              width: isNarrow ? 52 : 58,
              height: isNarrow ? 52 : 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium - 6,
                  ),
                  child: Image.asset(
                    'assets/images/galaxydox.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isNarrow
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Editorial-grade NASA explorer',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            notificationAction,
          ],
        );

        final actions = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _PanelIconButton(
              icon: Icons.travel_explore_rounded,
              tooltip: 'Search',
              size: iconButtonSize,
              onPressed: () => context.pushNamed(AppRoutes.searchName),
            ),
            _PanelIconButton(
              icon: Icons.bookmarks_rounded,
              tooltip: 'Bookmarks',
              size: iconButtonSize,
              onPressed: () => context.pushNamed(AppRoutes.bookmarksName),
            ),
            _PanelIconButton(
              icon: Icons.tune_rounded,
              tooltip: 'Settings',
              size: iconButtonSize,
              onPressed: () => context.pushNamed(AppRoutes.settingsName),
            ),
            _PanelIconButton(
              icon: Icons.info_outline_rounded,
              tooltip: 'About Me',
              size: iconButtonSize,
              onPressed: () => context.pushNamed(AppRoutes.aboutName),
            ),
            if (showDonationAction)
              _PanelIconButton(
                icon: Icons.volunteer_activism_outlined,
                tooltip: 'Donation',
                size: iconButtonSize,
                onPressed: () => context.pushNamed(AppRoutes.donationName),
              ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [brand, const SizedBox(height: 16), actions],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: brand),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    this.tooltip,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FrostedPanel(
        padding: EdgeInsets.zero,
        radius: AppConstants.radiusSmall,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Tooltip(
                message: tooltip ?? '',
                child: IconButton(
                  onPressed: onPressed,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: size,
                    height: size,
                  ),
                  icon: Icon(icon),
                ),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.backgroundDeep,
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
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

// ignore: unused_element
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

// ignore: unused_element
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
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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

// ignore: unused_element
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
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
