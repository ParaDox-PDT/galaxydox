import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';

class NasaInlineVideoPlayer extends StatefulWidget {
  const NasaInlineVideoPlayer({
    super.key,
    required this.playbackUrl,
    required this.posterUrl,
    this.videoFit = BoxFit.cover,
    this.overlayTitle,
    this.onBackPressed,
    this.onRotatePressed,
    this.onFullscreenPressed,
    this.fullscreenIcon = Icons.fullscreen_rounded,
    this.useSafeAreaInsets = false,
    this.controlsHideDelay = const Duration(seconds: 3),
    this.controlsBelowVideo = false,
  });

  final String playbackUrl;
  final String posterUrl;
  final BoxFit videoFit;
  final String? overlayTitle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onRotatePressed;
  final VoidCallback? onFullscreenPressed;
  final IconData fullscreenIcon;
  final bool useSafeAreaInsets;
  final Duration controlsHideDelay;
  final bool controlsBelowVideo;

  @override
  State<NasaInlineVideoPlayer> createState() => _NasaInlineVideoPlayerState();
}

class _NasaInlineVideoPlayerState extends State<NasaInlineVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  Object? _initializationError;
  Timer? _controlsHideTimer;
  Timer? _seekFeedbackTimer;
  bool _controlsVisible = true;
  bool _muted = false;
  bool _wasPlaying = false;
  bool _wasFinished = false;
  bool _isScrubbing = false;
  Duration? _scrubPreviewPosition;
  int _seekFeedbackDirection = 0;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant NasaInlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackUrl != widget.playbackUrl) {
      _disposeController();
      _createController();
    }
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _seekFeedbackTimer?.cancel();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _buildLoadingState();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return FutureBuilder<void>(
          future: _initializeFuture,
          builder: (context, snapshot) {
            final effectiveError =
                _initializationError ??
                snapshot.error ??
                (value.hasError ? value.errorDescription : null);

            if (snapshot.connectionState != ConnectionState.done &&
                !value.isInitialized &&
                effectiveError == null) {
              return _buildLoadingState();
            }

            if (effectiveError != null) {
              return _buildErrorState(effectiveError.toString());
            }

            if (!value.isInitialized) {
              return _buildLoadingState();
            }

            if (widget.controlsBelowVideo) {
              return _buildExpandedControlsLayout(value);
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleSurfaceTap,
              child: Stack(
                fit: StackFit.expand,
                children: [_buildOverlayVideoLayer(value)],
              ),
            );
          },
        );
      },
    );
  }

  void _createController() {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.playbackUrl),
      videoPlayerOptions: kIsWeb
          ? null
          : VideoPlayerOptions(
              allowBackgroundPlayback: false,
              mixWithOthers: false,
            ),
    );

    controller
      ..setLooping(false)
      ..addListener(_handleControllerValueChanged);
    final initializeFuture = _initializeController(controller);

    setState(() {
      _controller = controller;
      _initializationError = null;
      _initializeFuture = initializeFuture;
      _controlsVisible = true;
      _wasPlaying = false;
      _wasFinished = false;
    });
  }

  Future<void> _initializeController(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      if (!mounted || !identical(controller, _controller)) {
        return;
      }

      _showControls(autoHide: controller.value.isPlaying);
    } catch (error) {
      if (!mounted || !identical(controller, _controller)) {
        return;
      }

      setState(() {
        _initializationError = error;
      });
    }
  }

  void _handleControllerValueChanged() {
    final controller = _controller;
    if (!mounted || controller == null) {
      return;
    }

    final value = controller.value;
    final isPlaying = value.isPlaying;
    final isFinished = _isPlaybackFinished(value);

    if (isPlaying != _wasPlaying) {
      _wasPlaying = isPlaying;
      if (isPlaying) {
        _restartControlsHideTimer();
      } else {
        _showControls(autoHide: false);
      }
    }

    if (isFinished != _wasFinished) {
      _wasFinished = isFinished;
      if (isFinished) {
        _showControls(autoHide: false);
      }
    }
  }

  void _handleSurfaceTap() {
    if (_controlsVisible) {
      _hideControls();
      return;
    }

    final controller = _controller;
    _showControls(autoHide: controller?.value.isPlaying ?? false);
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
      _showControls(autoHide: false);
      return;
    }

    if (_isPlaybackFinished(controller.value)) {
      await controller.seekTo(Duration.zero);
    }

    await controller.play();
    _showControls(autoHide: true);
  }

  Future<void> _restartPlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    await controller.seekTo(Duration.zero);
    await controller.play();
    _showControls(autoHide: true);
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final nextMuted = !_muted;
    await controller.setVolume(nextMuted ? 0 : 1);
    if (!mounted) {
      return;
    }

    setState(() {
      _muted = nextMuted;
    });
    _showControls(autoHide: controller.value.isPlaying);
  }

  void _showControls({required bool autoHide}) {
    if (!mounted) {
      return;
    }

    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }

    if (autoHide) {
      _restartControlsHideTimer();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _hideControls() {
    _controlsHideTimer?.cancel();
    if (!mounted || !_controlsVisible) {
      return;
    }

    setState(() {
      _controlsVisible = false;
    });
  }

  void _restartControlsHideTimer() {
    _controlsHideTimer?.cancel();
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isPlaying) {
      return;
    }

    _controlsHideTimer = Timer(widget.controlsHideDelay, _hideControls);
  }

  bool _isPlaybackFinished(VideoPlayerValue value) {
    if (!value.isInitialized || value.duration == Duration.zero) {
      return false;
    }

    return value.position >= value.duration;
  }

  Widget _buildOverlayVideoLayer(VideoPlayerValue value) {
    final controller = _controller!;
    final topPadding = widget.useSafeAreaInsets
        ? MediaQuery.paddingOf(context).top + 14
        : 18.0;
    final bottomPadding = widget.useSafeAreaInsets
        ? MediaQuery.paddingOf(context).bottom + 14
        : 18.0;
    final showTopBar =
        widget.onBackPressed != null ||
        (widget.overlayTitle?.trim().isNotEmpty ?? false);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: widget.videoFit,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: value.size.width,
              height: value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: !_controlsVisible,
          child: AnimatedOpacity(
            opacity: _controlsVisible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.34),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.38),
                  ],
                  stops: const [0, 0.2, 0.68, 1],
                ),
              ),
            ),
          ),
        ),
        if (showTopBar)
          Positioned(
            top: topPadding,
            left: 16,
            right: 16,
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  children: [
                    if (widget.onBackPressed != null)
                      _ControlChipButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: widget.onBackPressed!,
                      ),
                    if (widget.onBackPressed != null) const SizedBox(width: 12),
                    if (widget.overlayTitle?.trim().isNotEmpty ?? false)
                      Expanded(
                        child: Text(
                          widget.overlayTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (_controlsVisible &&
            (!value.isPlaying || _isPlaybackFinished(value)))
          Center(
            child: _PlaybackButton(
              icon: _isPlaybackFinished(value)
                  ? Icons.replay_rounded
                  : Icons.play_arrow_rounded,
              onPressed: _togglePlayback,
            ),
          ),
        Positioned.fill(
          child: _SeekGestureOverlay(
            onSeekBackward: () => _seekRelative(const Duration(seconds: -10)),
            onSeekForward: () => _seekRelative(const Duration(seconds: 10)),
          ),
        ),
        if (_seekFeedbackDirection != 0)
          Center(
            child: _SeekFeedbackBadge(
              seconds: 10,
              forward: _seekFeedbackDirection > 0,
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: bottomPadding,
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: FrostedPanel(
                radius: 24,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                backgroundColor: AppColors.surfaceElevated.withValues(
                  alpha: 0.5,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSeekSlider(value),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _togglePlayback,
                          icon: Icon(
                            value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: AppColors.textPrimary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.textPrimary.withValues(
                                    alpha: 0.92,
                                  ),
                                ),
                          ),
                        ),
                        if (value.isBuffering)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        IconButton(
                          onPressed: _toggleMute,
                          icon: Icon(
                            _muted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: _restartPlayback,
                          icon: const Icon(
                            Icons.replay_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.onRotatePressed != null)
                          IconButton(
                            onPressed: widget.onRotatePressed,
                            icon: const Icon(
                              Icons.screen_rotation_alt_rounded,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (widget.onFullscreenPressed != null)
                          IconButton(
                            onPressed: widget.onFullscreenPressed,
                            icon: Icon(
                              widget.fullscreenIcon,
                              color: AppColors.textPrimary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedControlsLayout(VideoPlayerValue value) {
    final isFinished = _isPlaybackFinished(value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayback,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildVideoSurface(value),
                  Positioned.fill(
                    child: _SeekGestureOverlay(
                      onSeekBackward: () =>
                          _seekRelative(const Duration(seconds: -10)),
                      onSeekForward: () =>
                          _seekRelative(const Duration(seconds: 10)),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.16),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!value.isPlaying || isFinished)
                    Center(
                      child: _PlaybackButton(
                        icon: isFinished
                            ? Icons.replay_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: _togglePlayback,
                      ),
                    ),
                  if (_seekFeedbackDirection != 0)
                    Center(
                      child: _SeekFeedbackBadge(
                        seconds: 10,
                        forward: _seekFeedbackDirection > 0,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildControlsPanel(value, alwaysVisible: true),
      ],
    );
  }

  Widget _buildVideoSurface(VideoPlayerValue value) {
    final controller = _controller!;

    return Positioned.fill(
      child: FittedBox(
        fit: widget.videoFit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: value.size.width,
          height: value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Widget _buildControlsPanel(
    VideoPlayerValue value, {
    required bool alwaysVisible,
  }) {
    return IgnorePointer(
      ignoring: !alwaysVisible && !_controlsVisible,
      child: AnimatedOpacity(
        opacity: alwaysVisible || _controlsVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: FrostedPanel(
          radius: 24,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSeekSlider(value),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: _togglePlayback,
                    icon: Icon(
                      value.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                  if (value.isBuffering)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    onPressed: _toggleMute,
                    icon: Icon(
                      _muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _restartPlayback,
                    icon: const Icon(
                      Icons.replay_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.onRotatePressed != null)
                    IconButton(
                      onPressed: widget.onRotatePressed,
                      icon: const Icon(
                        Icons.screen_rotation_alt_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (widget.onFullscreenPressed != null)
                    IconButton(
                      onPressed: widget.onFullscreenPressed,
                      icon: Icon(
                        widget.fullscreenIcon,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    if (widget.controlsBelowVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String? errorDescription) {
    final content = Center(
      child: FrostedPanel(
        radius: 24,
        padding: const EdgeInsets.all(20),
        backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to start this NASA video.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (errorDescription != null && errorDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorDescription,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );

    if (widget.controlsBelowVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(aspectRatio: 16 / 9, child: content),
      );
    }

    return content;
  }

  void _disposeController() {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_handleControllerValueChanged);
    }
    _controller = null;
    _initializeFuture = null;
    _initializationError = null;
    controller?.dispose();
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSeekSlider(VideoPlayerValue value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: AppColors.secondary,
          inactiveTrackColor: AppColors.textPrimary.withValues(alpha: 0.14),
          secondaryActiveTrackColor: AppColors.textPrimary.withValues(
            alpha: 0.26,
          ),
          thumbColor: AppColors.textPrimary,
          overlayColor: AppColors.secondary.withValues(alpha: 0.18),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        ),
        child: Slider(
          value: _resolveSliderValue(value),
          secondaryTrackValue: _resolveBufferedSliderValue(value),
          min: 0,
          max: _resolveSliderMax(value),
          onChangeStart: (_) => _handleScrubStart(value),
          onChanged: _handleScrubChanged,
          onChangeEnd: _handleScrubEnd,
        ),
      ),
    );
  }

  double _resolveSliderMax(VideoPlayerValue value) {
    final totalMilliseconds = value.duration.inMilliseconds;
    return totalMilliseconds <= 0 ? 1 : totalMilliseconds.toDouble();
  }

  double _resolveSliderValue(VideoPlayerValue value) {
    final position =
        (_isScrubbing ? _scrubPreviewPosition : value.position) ??
        Duration.zero;
    return position.inMilliseconds
        .clamp(0, _resolveSliderMax(value).toInt())
        .toDouble();
  }

  double? _resolveBufferedSliderValue(VideoPlayerValue value) {
    if (value.buffered.isEmpty) {
      return null;
    }

    final buffered = value.buffered.last.end.inMilliseconds.toDouble();
    return buffered.clamp(0, _resolveSliderMax(value));
  }

  void _handleScrubStart(VideoPlayerValue value) {
    _controlsHideTimer?.cancel();
    setState(() {
      _isScrubbing = true;
      _scrubPreviewPosition = value.position;
    });
  }

  void _handleScrubChanged(double rawValue) {
    setState(() {
      _isScrubbing = true;
      _scrubPreviewPosition = Duration(milliseconds: rawValue.round());
    });
  }

  Future<void> _handleScrubEnd(double rawValue) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final target = Duration(milliseconds: rawValue.round());
    await controller.seekTo(target);
    if (!mounted) {
      return;
    }

    setState(() {
      _isScrubbing = false;
      _scrubPreviewPosition = null;
    });

    _showControls(autoHide: controller.value.isPlaying);
  }

  Future<void> _seekRelative(Duration offset) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final duration = controller.value.duration;
    final currentPosition = _isScrubbing
        ? (_scrubPreviewPosition ?? controller.value.position)
        : controller.value.position;
    final nextPosition = Duration(
      milliseconds: (currentPosition.inMilliseconds + offset.inMilliseconds)
          .clamp(0, duration.inMilliseconds),
    );

    await controller.seekTo(nextPosition);
    if (!mounted) {
      return;
    }

    setState(() {
      _isScrubbing = false;
      _scrubPreviewPosition = null;
      _seekFeedbackDirection = offset.isNegative ? -1 : 1;
    });

    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _seekFeedbackDirection = 0;
      });
    });

    _showControls(autoHide: controller.value.isPlaying);
  }
}

class _PlaybackButton extends StatelessWidget {
  const _PlaybackButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.34),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.18),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        iconSize: 42,
        padding: const EdgeInsets.all(18),
        icon: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ControlChipButton extends StatelessWidget {
  const _ControlChipButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _SeekGestureOverlay extends StatelessWidget {
  const _SeekGestureOverlay({
    required this.onSeekBackward,
    required this.onSeekForward,
  });

  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: onSeekBackward,
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: onSeekForward,
          ),
        ),
      ],
    );
  }
}

class _SeekFeedbackBadge extends StatelessWidget {
  const _SeekFeedbackBadge({required this.seconds, required this.forward});

  final int seconds;
  final bool forward;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.18),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                forward ? Icons.forward_10_rounded : Icons.replay_10_rounded,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                forward ? '+$seconds sec' : '-$seconds sec',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
