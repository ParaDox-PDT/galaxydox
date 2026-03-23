import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/aurora_background.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';

class AuroraDemoPage extends StatelessWidget {
  const AuroraDemoPage({super.key});

  static const List<AuroraPaletteSet> _demoPaletteSets = [
    AuroraPaletteSet([
      Color(0xFF091321),
      Color(0xFF14305E),
      Color(0xFF2456A7),
      Color(0xFF1D84D8),
      Color(0xFF53D8FF),
      Color(0xFF705AF3),
      Color(0xFFF3F8FF),
    ]),
    AuroraPaletteSet([
      Color(0xFF08111F),
      Color(0xFF1B2758),
      Color(0xFF3951B7),
      Color(0xFF2D73D9),
      Color(0xFF39C5F4),
      Color(0xFF8B55F0),
      Color(0xFFE8F3FF),
    ]),
    AuroraPaletteSet([
      Color(0xFF09101E),
      Color(0xFF122A4B),
      Color(0xFF214C86),
      Color(0xFF2489C8),
      Color(0xFF5BE6FF),
      Color(0xFF615EE6),
      Color(0xFFF6FAFF),
    ]),
    AuroraPaletteSet([
      Color(0xFF07111D),
      Color(0xFF183468),
      Color(0xFF2E4FA4),
      Color(0xFF2877C2),
      Color(0xFF49B6EB),
      Color(0xFF7E65F7),
      Color(0xFFEAF6FF),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        paletteSets: _demoPaletteSets,
        animationDuration: const Duration(seconds: 48),
        blurStrength: 58,
        opacity: 0.9,
        blobCount: 7,
        enableNoiseOverlay: true,
        enableVignette: true,
        speedMultiplier: 0.94,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidthCompact,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pagePadding,
                    16,
                    AppConstants.pagePadding,
                    36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeader(
                        title: 'Aurora Motion Lab',
                        subtitle:
                            'A safe demo route for a cinematic, NASA-inspired background system. It lives outside the main product flow and is ready to be reused anywhere we want a premium atmospheric scene.',
                        actions: [
                          FilledButton.icon(
                            onPressed: () => context.goNamed(AppRoutes.homeName),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Mission Control'),
                          ),
                        ],
                      ).animate().fadeIn(duration: 420.ms).slideY(
                        begin: -0.04,
                        end: 0,
                      ),
                      const SizedBox(height: 24),
                      const _HeroShowcase()
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 520.ms)
                          .slideY(begin: 0.04, end: 0),
                      const SizedBox(height: 24),
                      const _SystemOverview()
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 520.ms)
                          .slideY(begin: 0.04, end: 0),
                      const SizedBox(height: 24),
                      const _CustomizationAndPerformance()
                          .animate()
                          .fadeIn(delay: 260.ms, duration: 520.ms)
                          .slideY(begin: 0.04, end: 0),
                    ],
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

class _HeroShowcase extends StatelessWidget {
  const _HeroShowcase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      backgroundColor: const Color(0xFF081226).withValues(alpha: 0.72),
      blurSigma: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  AppChip(label: 'Cinematic'),
                  AppChip(label: 'Fluid Mesh Gradient'),
                  AppChip(label: 'Dark-Mode Safe'),
                  AppChip(label: 'Reusable Widget'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Nebula-grade atmosphere for premium NASA storytelling.',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 14),
              Text(
                'AuroraBackground now combines scene-wide palette evolution, independent blob drift, soft scale breathing, and color interpolation across multiple NASA-inspired states so the light never feels frozen in place.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.86),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _MetricChip(
                    label: 'Palette',
                    value: '4 evolving color states',
                  ),
                  _MetricChip(label: 'Loop', value: '48s cinematic cycle'),
                  _MetricChip(label: 'Motion', value: 'Drift, breathe, morph'),
                ],
              ),
            ],
          );

          final previewPanel = FrostedPanel(
            padding: const EdgeInsets.all(22),
            backgroundColor: const Color(0xFF0A162C).withValues(alpha: 0.76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryStrong.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      child: const Icon(Icons.satellite_alt_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Orbital window', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Foreground readability check',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Europa Relay Pass',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Signal stability holds while the background remains atmospheric and calm. This is the balance we want for story pages, data panes, and immersive onboarding moments.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                const _TelemetryRow(
                  label: 'Glow intensity',
                  value: '0.90',
                  accent: AppColors.primaryStrong,
                ),
                const SizedBox(height: 12),
                const _TelemetryRow(
                  label: 'Palette states',
                  value: '4',
                  accent: Color(0xFF52D8FF),
                ),
                const SizedBox(height: 12),
                const _TelemetryRow(
                  label: 'Speed multiplier',
                  value: '0.94x',
                  accent: Color(0xFF7A74FF),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 22),
                previewPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: previewPanel),
            ],
          );
        },
      ),
    );
  }
}

class _SystemOverview extends StatelessWidget {
  const _SystemOverview();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 940;
        final spacing = 20.0;
        final itemWidth = wide
            ? (constraints.maxWidth - (spacing * 2)) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(width: itemWidth, child: const _ImplementationCard()),
            SizedBox(width: itemWidth, child: const _StructureCard()),
            SizedBox(width: itemWidth, child: const _PremiumAdditionsCard()),
          ],
        );
      },
    );
  }
}

class _CustomizationAndPerformance extends StatelessWidget {
  const _CustomizationAndPerformance();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final left = const _CustomizationCard();
        final right = const _PerformanceCard();

        if (compact) {
          return Column(
            children: [
              left,
              const SizedBox(height: 20),
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: _CustomizationCard()),
            const SizedBox(width: 20),
            const Expanded(child: _PerformanceCard()),
          ],
        );
      },
    );
  }
}

class _ImplementationCard extends StatelessWidget {
  const _ImplementationCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      eyebrow: 'Why this method',
      title: 'Purpose-built for fluid premium motion',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BulletLine(
            text:
                'CustomPainter keeps the effect package-free, predictable, and easy to integrate into any screen.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text:
                'A dedicated atmosphere layer plus two blurred blob layers creates depth without resorting to heavy mesh packages.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text:
                'Sine and cosine phase offsets drive continuous drift, scale breathing, opacity changes, and non-robotic motion.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text:
                'Palette interpolation lets blues, cyans, indigos, and violets transform smoothly over time with no hard jumps.',
          ),
        ],
      ),
    );
  }
}

class _StructureCard extends StatelessWidget {
  const _StructureCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      eyebrow: 'File structure',
      title: 'What was added for this safe prototype',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StructureLine(path: 'lib/shared/widgets/aurora_background.dart'),
          SizedBox(height: 10),
          _StructureLine(path: 'lib/features/demo/presentation/pages/aurora_demo_page.dart'),
          SizedBox(height: 10),
          _StructureLine(path: 'lib/app/router/app_routes.dart'),
          SizedBox(height: 10),
          _StructureLine(path: 'lib/app/router/app_router.dart'),
          SizedBox(height: 10),
          _StructureLine(path: 'lib/features/home/presentation/pages/home_page.dart'),
        ],
      ),
    );
  }
}

class _PremiumAdditionsCard extends StatelessWidget {
  const _PremiumAdditionsCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      eyebrow: 'Premium additions',
      title: 'Atmosphere without visual clutter',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BulletLine(
            text: 'Subtle vignette keeps focus toward the center of the scene.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text: 'Optional fine-grain noise prevents the background from feeling digitally flat.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text: 'Soft horizon glow adds a nebula-like light band for extra depth.',
          ),
        ],
      ),
    );
  }
}

class _CustomizationCard extends StatelessWidget {
  const _CustomizationCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      eyebrow: 'Customization',
      title: 'Parameters exposed by AuroraBackground',
      child: const Column(
        children: [
          _ControlRow(
            label: 'colors / paletteSets',
            description: 'Use a base color list or provide explicit evolving palette states for richer scene transitions.',
          ),
          SizedBox(height: 12),
          _ControlRow(
            label: 'blobCount',
            description: 'Increase density for richer glow fields, reduce for quieter scenes.',
          ),
          SizedBox(height: 12),
          _ControlRow(
            label: 'animationDuration',
            description: 'Controls how long the full palette and motion loop takes before repeating seamlessly.',
          ),
          SizedBox(height: 12),
          _ControlRow(
            label: 'blurStrength',
            description: 'Tune softness from atmospheric haze to stronger bloom.',
          ),
          SizedBox(height: 12),
          _ControlRow(
            label: 'speedMultiplier',
            description: 'Scales the pace of drift and color evolution while preserving smooth looping.',
          ),
          SizedBox(height: 12),
          _ControlRow(
            label: 'opacity',
            description: 'Balances visual richness with content legibility.',
          ),
          SizedBox(height: 12),
          _ControlRow(
            label: 'enableVignette / enableNoiseOverlay',
            description: 'Turn premium finishing layers on or off per screen.',
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      eyebrow: 'Performance notes',
      title: 'Tuned for real devices',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BulletLine(
            text: 'The painters are driven directly by the animation controller, so frame updates repaint only the effect instead of rebuilding the widget tree.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text: 'Animated layers are wrapped in a RepaintBoundary to isolate expensive blur and painter work from foreground content.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text: 'The noise overlay stays static, which adds texture without spending frame budget on unnecessary animation.',
          ),
          SizedBox(height: 12),
          _BulletLine(
            text: 'If a screen becomes content-heavy, lower blobCount or blurStrength first for the most predictable savings.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      backgroundColor: const Color(0xFF091327).withValues(alpha: 0.76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: const BoxDecoration(
            color: AppColors.primaryStrong,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TelemetryRow extends StatelessWidget {
  const _TelemetryRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withValues(alpha: 0.34)),
          ),
          child: Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _StructureLine extends StatelessWidget {
  const _StructureLine({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Text(
        path,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({required this.label, required this.description});

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(description, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
