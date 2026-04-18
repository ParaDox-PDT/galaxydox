import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/analytics/analytics_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../data/models/resolved_planet_model.dart';
import '../../domain/planet_entity.dart';
import '../providers/planets_providers.dart';

const _fallbackPlanetThumbnailAsset = 'assets/images/planets.png';

class PlanetDetailPage extends ConsumerWidget {
  const PlanetDetailPage({super.key, required this.planetId});

  final String planetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planetAsync = ref.watch(planetProvider(planetId));

    return planetAsync.when(
      loading: () => const _DetailShell(
        child: _CenteredStatus(
          title: 'Loading planet',
          message: 'Getting this planet ready for you...',
          icon: Icons.cloud_download_rounded,
        ),
      ),
      error: (error, stackTrace) => _DetailShell(
        child: StatePanel(
          title: 'Unable to load planet',
          message: _resolveAsyncErrorMessage(error),
          icon: Icons.error_outline_rounded,
          accent: AppColors.warning,
          actions: [
            StatePanelAction(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: () {
                ref.invalidate(planetProvider(planetId));
              },
            ),
            StatePanelAction(
              label: 'Go back',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).maybePop(),
              emphasis: StatePanelActionEmphasis.secondary,
            ),
          ],
        ),
      ),
      data: (planet) {
        if (planet == null) {
          return _DetailShell(
            child: StatePanel(
              title: 'Planet not found',
              message:
                  'This document does not exist in the Firebase `planets` collection.',
              icon: Icons.public_off_rounded,
              accent: AppColors.secondary,
              actions: [
                StatePanelAction(
                  label: 'Go back',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          );
        }

        return _PlanetDetailContent(planet: planet);
      },
    );
  }

  static String _resolveAsyncErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Planet details could not be loaded right now.';
  }
}

class _PlanetDetailContent extends ConsumerStatefulWidget {
  const _PlanetDetailContent({required this.planet});

  final PlanetEntity planet;

  @override
  ConsumerState<_PlanetDetailContent> createState() =>
      _PlanetDetailContentState();
}

class _PlanetDetailContentState extends ConsumerState<_PlanetDetailContent> {
  static const _modelViewerChannelName = 'ModelViewerLoadingChannel';

  ResolvedPlanetModel? _resolvedModel;
  String? _modelError;
  double? _downloadProgress;
  double _modelLoadProgress = 0;
  bool _isPreparingModel = false;
  bool _isModelViewerLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logPlanetViewed(
        planetId: widget.planet.id,
        planetName: widget.planet.title,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _PlanetDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.planet.id != widget.planet.id ||
        oldWidget.planet.modelUrl != widget.planet.modelUrl) {
      _prepareModel();
    }
  }

  Future<void> _prepareModel() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _resolvedModel = null;
      _modelError = null;
      _downloadProgress = null;
      _modelLoadProgress = 0;
      _isPreparingModel = true;
      _isModelViewerLoading = false;
    });

    try {
      final resolvedModel = await ref
          .read(planetModelCacheServiceProvider)
          .prepareModel(
            planetId: widget.planet.id,
            modelUrl: widget.planet.modelUrl,
            onDownloadProgress: (progress) {
              if (!mounted) {
                return;
              }

              setState(() {
                _downloadProgress = progress;
                _isPreparingModel = true;
              });
            },
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _resolvedModel = resolvedModel;
        _downloadProgress = 1;
        _isPreparingModel = false;
        // On web, JavascriptChannel is unavailable so the load event never
        // arrives — skip the overlay entirely since download already tracked.
        _isModelViewerLoading = !kIsWeb;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _modelError = error is AppException
            ? error.message
            : 'Could not prepare the 3D model.';
        _resolvedModel = null;
        _downloadProgress = null;
        _modelLoadProgress = 0;
        _isPreparingModel = false;
        _isModelViewerLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planet = widget.planet;

    return SpaceScaffold(
      topSafeArea: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              ),
            ),
            leadingWidth: 123,
            title: Text(planet.title),
            centerTitle: false,
            pinned: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: IconButton(
                    onPressed: () => _showStorageInfoSheet(context),
                    tooltip: 'How model loading works',
                    icon: const Icon(Icons.info_outline_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.22),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0.42),
                    AppColors.backgroundDeep.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pagePadding,
                    16,
                    AppConstants.pagePadding,
                    42,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModelViewer(context),
                      const SizedBox(height: 24),
                      _buildInfoSection(context, theme, planet),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleModelViewerMessage(dynamic message) {
    try {
      final payload = jsonDecode(message.message);
      if (payload is! Map<String, dynamic>) {
        return;
      }

      final type = payload['type'];
      if (type == 'progress') {
        final progress = (payload['progress'] as num?)?.toDouble() ?? 0;
        if (!mounted) {
          return;
        }
        setState(() {
          _modelLoadProgress = progress.clamp(0.0, 1.0);
          _isModelViewerLoading = _modelLoadProgress < 1;
        });
        return;
      }

      if (type == 'loaded') {
        if (!mounted) {
          return;
        }
        setState(() {
          _modelLoadProgress = 1;
          _isModelViewerLoading = false;
        });
        return;
      }

      if (type == 'error' && mounted) {
        setState(() {
          _modelError = 'Could not render the 3D model.';
          _resolvedModel = null;
          _modelLoadProgress = 0;
          _isModelViewerLoading = false;
        });
      }
    } catch (_) {
      // Ignore malformed messages coming from the embedded WebView.
    }
  }

  Set<JavascriptChannel> _buildModelViewerChannels() {
    return {
      JavascriptChannel(
        _modelViewerChannelName,
        onMessageReceived: _handleModelViewerMessage,
      ),
    };
  }

  String _buildModelViewerBridgeScript() {
    return '''
      const modelViewer = document.querySelector('model-viewer');
      const loadingChannel = window.$_modelViewerChannelName;

      if (modelViewer && loadingChannel) {
        const sendMessage = (payload) => {
          loadingChannel.postMessage(JSON.stringify(payload));
        };

        modelViewer.addEventListener('progress', (event) => {
          const detail = event.detail || {};
          const progress = typeof detail.totalProgress === 'number'
              ? detail.totalProgress
              : 0;
          sendMessage({ type: 'progress', progress });
        });

        modelViewer.addEventListener('load', () => {
          sendMessage({ type: 'loaded' });
        });

        modelViewer.addEventListener('error', () => {
          sendMessage({ type: 'error' });
        });
      }
    ''';
  }

  Widget _buildModelViewer(BuildContext context) {
    final planet = widget.planet;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: planet.accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: planet.accentColor.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    planet.accentColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            if (_modelError != null)
              _ModelErrorState(message: _modelError!, onRetry: _prepareModel)
            else if (_resolvedModel == null)
              _ModelLoadingState(
                accentColor: planet.accentColor,
                title: _isPreparingModel
                    ? 'Getting the 3D model ready...'
                    : 'Preparing the 3D view...',
                subtitle:
                    'We are saving this model on your device so it can open faster next time.',
                progress: _downloadProgress,
              )
            else
              Stack(
                fit: StackFit.expand,
                children: [
                  ModelViewer(
                    backgroundColor: Colors.transparent,
                    src: _resolvedModel!.viewerSrc,
                    alt: '3D model of ${planet.title}',
                    autoRotate: true,
                    autoRotateDelay: 0,
                    rotationPerSecond: '18deg',
                    cameraControls: true,
                    disableZoom: false,
                    disableTap: false,
                    disablePan: true,
                    exposure: 0.8,
                    innerModelViewerHtml:
                        '<div class="mv-hidden-progress" slot="progress-bar"></div>',
                    relatedCss: '''
                      .mv-hidden-progress {
                        display: none;
                      }
                    ''',
                    relatedJs: kIsWeb ? '' : _buildModelViewerBridgeScript(),
                    javascriptChannels:
                        kIsWeb ? {} : _buildModelViewerChannels(),
                    debugLogging: false,
                  ),
                  if (_isModelViewerLoading)
                    IgnorePointer(
                      child: _ModelViewerProgressOverlay(
                        progress: _modelLoadProgress,
                      ),
                    ),
                ],
              ),
            Positioned(
              top: 12,
              left: 12,
              child: _StorageBadge(
                accentColor: planet.accentColor,
                label: _storageLabel,
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Drag to rotate - Pinch to zoom',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_resolvedModel != null)
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      SwipeBackPageRoute<void>(
                        builder: (context) => _FullScreenModelPage(
                          planet: planet,
                          modelUrl: _resolvedModel!.viewerSrc,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.04, end: 0);
  }

  Future<void> _showStorageInfoSheet(BuildContext context) {
    final theme = Theme.of(context);
    final planet = widget.planet;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDeep.withValues(alpha: 0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final normalizedProgress = _downloadProgress?.clamp(0.0, 1.0);

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: planet.accentColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: planet.accentColor.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: planet.accentColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How model loading works',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This helps explain where the 3D model is opening from right now.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FrostedPanel(
                  padding: const EdgeInsets.all(18),
                  borderColor: planet.accentColor.withValues(alpha: 0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusChip(
                        label: _storageLabel,
                        accentColor: planet.accentColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _storageDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      if (normalizedProgress != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: normalizedProgress,
                            minHeight: 8,
                            color: planet.accentColor,
                            backgroundColor: planet.accentColor.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(normalizedProgress * 100).round()}% ready',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: planet.accentColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FrostedPanel(
                  padding: const EdgeInsets.all(18),
                  borderColor: planet.accentColor.withValues(alpha: 0.14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happens behind the scenes',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      _InfoStep(
                        icon: Icons.download_rounded,
                        title: 'First open',
                        description:
                            'We download the model once and save it on your device.',
                      ),
                      const SizedBox(height: 12),
                      _InfoStep(
                        icon: Icons.offline_bolt_rounded,
                        title: 'Next opens',
                        description:
                            'If the saved copy is available, the model opens faster without downloading again.',
                      ),
                      const SizedBox(height: 12),
                      _InfoStep(
                        icon: Icons.wifi_tethering_rounded,
                        title: 'If saving is not available',
                        description:
                            'On some devices or platforms, the model may open directly from the internet instead.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Close'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _prepareModel();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reload model'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    ThemeData theme,
    PlanetEntity planet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Hero(
                  tag: 'planet_thumb_${planet.id}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: planet.accentColor.withValues(alpha: 0.24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _PlanetThumbnail(
                        planet: planet,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planet.title, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        planet.subtitle.isEmpty
                            ? 'Interactive 3D experience'
                            : planet.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: planet.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 480.ms)
            .slideY(begin: 0.04, end: 0),
        const SizedBox(height: 20),
        Text(
              planet.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 480.ms)
            .slideY(begin: 0.04, end: 0),
        if (planet.facts.isNotEmpty) ...[
          const SizedBox(height: 24),
          FrostedPanel(
                padding: const EdgeInsets.all(20),
                borderColor: planet.accentColor.withValues(alpha: 0.18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Facts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: planet.accentColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final fact in planet.facts) ...[
                      _FactRow(fact: fact, accentColor: planet.accentColor),
                      if (fact != planet.facts.last) const SizedBox(height: 10),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 420.ms, duration: 480.ms)
              .slideY(begin: 0.04, end: 0),
        ],
      ],
    );
  }

  String get _storageLabel {
    if (_resolvedModel == null) {
      return _isPreparingModel ? 'Downloading now' : 'Getting ready';
    }

    if (!_resolvedModel!.isStoredLocally) {
      return 'Opening online';
    }

    return _resolvedModel!.wasLoadedFromCache
        ? 'Opened from device'
        : 'Saved for next time';
  }

  String get _storageDescription {
    if (_modelError != null) {
      return 'We could not get the 3D model ready. Please try loading it again.';
    }

    if (_resolvedModel == null) {
      return _isPreparingModel
          ? 'This 3D model is being downloaded and saved on your device.'
          : 'We are getting everything ready so the 3D view can open smoothly.';
    }

    if (!_resolvedModel!.isStoredLocally) {
      return 'This model is opening directly from the internet on this device.';
    }

    if (_resolvedModel!.wasLoadedFromCache) {
      return 'This 3D model opened from your device, so no new download was needed.';
    }

    return 'This 3D model was downloaded and saved on your device, so the next open should be faster.';
  }
}

class _PlanetThumbnail extends StatelessWidget {
  const _PlanetThumbnail({required this.planet, this.fit = BoxFit.cover});

  final PlanetEntity planet;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (planet.thumbnailUrl.isNotEmpty) {
      return PremiumNetworkImage(imageUrl: planet.thumbnailUrl, fit: fit);
    }

    return Image.asset(
      _fallbackPlanetThumbnailAsset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          _ThumbnailFallback(accentColor: planet.accentColor),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accentColor.withValues(alpha: 0.1),
      child: Icon(Icons.public_rounded, color: accentColor, size: 28),
    );
  }
}

class _StorageBadge extends StatelessWidget {
  const _StorageBadge({required this.accentColor, required this.label});

  final Color accentColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done_rounded, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: accentColor),
      ),
    );
  }
}

class _DetailShell extends StatelessWidget {
  const _DetailShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SpaceScaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidthCompact,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return StatePanel(
      title: title,
      message: message,
      icon: icon,
      accent: AppColors.primary,
    );
  }
}

class _ModelLoadingState extends StatelessWidget {
  const _ModelLoadingState({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    this.progress,
  });

  final Color accentColor;
  final String title;
  final String subtitle;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress?.clamp(0.0, 1.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: CircularProgressIndicator(
                value: normalizedProgress,
                strokeWidth: 4,
                color: accentColor,
                backgroundColor: accentColor.withValues(alpha: 0.18),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (normalizedProgress != null) ...[
              const SizedBox(height: 14),
              Text(
                '${(normalizedProgress * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: accentColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModelViewerProgressOverlay extends StatelessWidget {
  const _ModelViewerProgressOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final progressLabel = '${(normalizedProgress * 100).round()}%';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.42),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: normalizedProgress > 0 ? normalizedProgress : null,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
                Center(
                  child: Text(
                    progressLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Almost there...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModelErrorState extends StatelessWidget {
  const _ModelErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.26),
                ),
              ),
              child: const Icon(
                Icons.view_in_ar_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to render model',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact, required this.accentColor});

  final String fact;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            fact,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _FullScreenModelPage extends StatelessWidget {
  const _FullScreenModelPage({required this.planet, required this.modelUrl});

  final PlanetEntity planet;
  final String modelUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  planet.accentColor.withValues(alpha: 0.15),
                  Colors.black,
                ],
              ),
            ),
          ),
          ModelViewer(
            backgroundColor: Colors.transparent,
            src: modelUrl,
            alt: '3D model of ${planet.title}',
            autoRotate: true,
            autoRotateDelay: 0,
            rotationPerSecond: '10deg',
            cameraControls: true,
            disableZoom: false,
            disableTap: false,
            disablePan: false,
            exposure: 1.0,
            debugLogging: false,
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.threesixty_rounded,
                      size: 20,
                      color: planet.accentColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Drag to rotate - Pinch to zoom',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
