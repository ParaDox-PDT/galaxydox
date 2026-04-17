import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../data/local_model_server.dart';
import '../../data/planets_catalog.dart';
import '../../domain/planet_entity.dart';

class PlanetDetailPage extends StatelessWidget {
  const PlanetDetailPage({super.key, required this.planetId});

  final String planetId;

  @override
  Widget build(BuildContext context) {
    final planet = PlanetsCatalog.planets
        .where((p) => p.id == planetId)
        .firstOrNull;

    if (planet == null) {
      return SpaceScaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Planet not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go back'),
              ),
            ],
          ),
        ),
      );
    }

    return _PlanetDetailContent(planet: planet);
  }
}

class _PlanetDetailContent extends StatefulWidget {
  const _PlanetDetailContent({required this.planet});

  final PlanetEntity planet;

  @override
  State<_PlanetDetailContent> createState() => _PlanetDetailContentState();
}

class _PlanetDetailContentState extends State<_PlanetDetailContent> {
  static const _modelViewerChannelName = 'ModelViewerLoadingChannel';

  String? _modelUrl;
  String? _modelError;
  double _modelLoadProgress = 0;
  bool _isModelViewerLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareModel();
  }

  Future<void> _prepareModel() async {
    try {
      final url = await LocalModelServer.instance.serveAsset(
        widget.planet.modelAssetPath,
      );
      if (mounted) {
        setState(() {
          _modelUrl = url;
          _modelLoadProgress = 0;
          _isModelViewerLoading = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _modelError = 'Could not load 3D model: ${e.toString()}',
        );
      }
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
          _modelUrl = null;
          _modelError = 'Could not render the 3D model.';
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
              _ModelErrorState(
                message: _modelError!,
                onRetry: () {
                  setState(() {
                    _modelError = null;
                    _modelUrl = null;
                    _modelLoadProgress = 0;
                    _isModelViewerLoading = false;
                  });
                  _prepareModel();
                },
              )
            else if (_modelUrl == null)
              _ModelLoadingState(accentColor: planet.accentColor)
            else
              Stack(
                fit: StackFit.expand,
                children: [
                  ModelViewer(
                    backgroundColor: Colors.transparent,
                    src: _modelUrl!,
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
                    relatedJs: _buildModelViewerBridgeScript(),
                    javascriptChannels: _buildModelViewerChannels(),
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
            if (_modelUrl != null)
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => _FullScreenModelPage(
                          planet: planet,
                          modelUrl: _modelUrl!,
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
                      child: Image.asset(
                        planet.thumbnailAssetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: planet.accentColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.public_rounded,
                            color: planet.accentColor,
                            size: 28,
                          ),
                        ),
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
                        planet.subtitle,
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
}

class _ModelLoadingState extends StatelessWidget {
  const _ModelLoadingState({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading 3D model...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
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
            'Loading 3D model...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ModelErrorState extends StatelessWidget {
  const _ModelErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
              maxLines: 3,
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
