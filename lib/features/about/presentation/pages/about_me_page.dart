import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/ambient_space_background.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  static const _portfolioUrl = 'https://portfoliodox.uz';
  static const _socialLinks = [
    (
      tooltip: 'Telegram',
      assetPath: 'assets/icons/telegram.svg',
      url: 'https://t.me/Paradox358',
    ),
    (
      tooltip: 'LinkedIn',
      assetPath: 'assets/icons/linkedin.svg',
      url: 'https://www.linkedin.com/in/doniyor-jo-rabekov-b9aa40250/',
    ),
    (
      tooltip: 'GitHub',
      assetPath: 'assets/icons/github.svg',
      url: 'https://github.com/ParaDox-PDT',
    ),
  ];
  static const _description =
      'Flutter Developer with 3+ years of experience building scalable, production-ready mobile apps.\n'
      'Specialized in Clean Architecture, BLoC, and real-time features.\n'
      'Worked on logistics, healthcare, and service platforms \u2014 focusing on performance and user experience.';

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open $url')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientSpaceBackground(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  AppColors.backgroundDeep.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = width < 390 ? 16.0 : 24.0;
                final imageSize = width < 390
                    ? width - (horizontalPadding * 2)
                    : (width * 0.62).clamp(230.0, 320.0);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                  'About Me',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                )
                                .animate()
                                .fadeIn(duration: 450.ms)
                                .slideY(begin: -0.18, end: 0),
                            const SizedBox(height: 28),
                            _ProfileImage(size: imageSize)
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 520.ms)
                                .scale(
                                  begin: const Offset(0.94, 0.94),
                                  end: const Offset(1, 1),
                                  curve: Curves.easeOutCubic,
                                ),
                            const SizedBox(height: 18),
                            Text(
                                  'ParaDox',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.primaryStrong
                                                .withValues(alpha: 0.22),
                                            blurRadius: 18,
                                          ),
                                        ],
                                      ),
                                )
                                .animate()
                                .fadeIn(delay: 140.ms, duration: 500.ms)
                                .slideY(begin: 0.08, end: 0),
                            const SizedBox(height: 24),
                            _GlassLinkButton(
                                  label: 'portfoliodox.uz',
                                  onTap: () =>
                                      _openLink(context, _portfolioUrl),
                                )
                                .animate()
                                .fadeIn(delay: 180.ms, duration: 520.ms)
                                .slideY(begin: 0.12, end: 0),
                            const SizedBox(height: 16),
                            Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final item in _socialLinks)
                                      _SocialLinkButton(
                                        tooltip: item.tooltip,
                                        assetPath: item.assetPath,
                                        onTap: () =>
                                            _openLink(context, item.url),
                                      ),
                                  ],
                                )
                                .animate()
                                .fadeIn(delay: 220.ms, duration: 540.ms)
                                .slideY(begin: 0.14, end: 0),
                            const SizedBox(height: 24),
                            Text(
                                  _description,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFFCCCCCC),
                                    height: 1.72,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 260.ms, duration: 560.ms)
                                .slideY(begin: 0.16, end: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              bottom: false,
              child: _BackButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                    return;
                  }

                  context.goNamed(AppRoutes.homeName);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryStrong.withValues(alpha: 0.42),
            Colors.white.withValues(alpha: 0.06),
            AppColors.tertiary.withValues(alpha: 0.22),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStrong.withValues(alpha: 0.18),
            blurRadius: 48,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/profile.png', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.25,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.28),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassLinkButton extends StatelessWidget {
  const _GlassLinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.white.withValues(alpha: 0.06),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryStrong.withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: IconButton(
            onPressed: onPressed,
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
      ),
    );
  }
}

class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({
    required this.tooltip,
    required this.assetPath,
    required this.onTap,
  });

  final String tooltip;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.white.withValues(alpha: 0.05),
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStrong.withValues(alpha: 0.1),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
