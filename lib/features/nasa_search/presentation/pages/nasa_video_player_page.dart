import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/nasa_inline_video_player.dart';

class NasaVideoPlayerPage extends StatefulWidget {
  const NasaVideoPlayerPage({
    super.key,
    required this.title,
    required this.playbackUrl,
    required this.posterUrl,
    this.subtitle,
  });

  final String title;
  final String playbackUrl;
  final String posterUrl;
  final String? subtitle;

  @override
  State<NasaVideoPlayerPage> createState() => _NasaVideoPlayerPageState();
}

class _NasaVideoPlayerPageState extends State<NasaVideoPlayerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterFullscreenMode();
    });
  }

  @override
  void dispose() {
    _restoreSystemUi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NasaInlineVideoPlayer(
        playbackUrl: widget.playbackUrl,
        posterUrl: widget.posterUrl,
        videoFit: BoxFit.contain,
        overlayTitle: widget.title,
        onBackPressed: _closePage,
        onRotatePressed: _toggleOrientation,
        onFullscreenPressed: _closePage,
        fullscreenIcon: Icons.fullscreen_exit_rounded,
        useSafeAreaInsets: true,
      ),
    );
  }

  Future<void> _enterFullscreenMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const []);
  }

  Future<void> _toggleOrientation() async {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    if (isLandscape) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _closePage() async {
    await _restoreSystemUi();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
