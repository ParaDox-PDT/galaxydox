import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/trusted_external_url.dart';
import '../../../../shared/navigation/swipe_back_route.dart';
import '../../../nasa_search/presentation/pages/nasa_video_player_page.dart';
import '../../domain/entities/apod_item.dart';

Future<void> openApodVideoPlayer(
  BuildContext context, {
  required ApodItem item,
}) async {
  final videoUri = sanitizeTrustedExternalUri(
    item.url,
    allowedHosts: TrustedHostSets.nasaAndVideoHosts,
  );

  if (videoUri == null) {
    _showLaunchError(context);
    return;
  }

  if (!kIsWeb && _isDirectPlaybackVideo(videoUri)) {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      SwipeBackPageRoute<void>(
        builder: (context) => NasaVideoPlayerPage(
          title: item.title,
          subtitle: item.explanation,
          playbackUrl: videoUri.toString(),
          posterUrl: resolveApodVideoPosterUrl(item) ?? '',
        ),
      ),
    );
    return;
  }

  final launched = await launchUrl(
    _buildInAppVideoUri(videoUri),
    mode: LaunchMode.inAppWebView,
    webViewConfiguration: const WebViewConfiguration(
      enableJavaScript: true,
      enableDomStorage: true,
    ),
  );

  if (!launched && context.mounted) {
    _showLaunchError(context);
  }
}

String? resolveApodVideoPosterUrl(ApodItem item) {
  final thumbnailUrl = item.thumbnailUrl?.trim();
  if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
    return thumbnailUrl;
  }

  return _buildYoutubeThumbnail(Uri.tryParse(item.url));
}

bool _isDirectPlaybackVideo(Uri uri) {
  final normalizedPath = uri.path.toLowerCase();

  return normalizedPath.endsWith('.mp4') ||
      normalizedPath.endsWith('.m4v') ||
      normalizedPath.endsWith('.mov') ||
      normalizedPath.endsWith('.m3u8') ||
      normalizedPath.endsWith('.webm');
}

Uri _buildInAppVideoUri(Uri uri) {
  final youtubeEmbedUri = _buildYoutubeEmbedUri(uri);
  if (youtubeEmbedUri != null) {
    return youtubeEmbedUri;
  }

  final vimeoEmbedUri = _buildVimeoEmbedUri(uri);
  if (vimeoEmbedUri != null) {
    return vimeoEmbedUri;
  }

  return uri;
}

Uri? _buildYoutubeEmbedUri(Uri uri) {
  final host = uri.host.toLowerCase();
  String? videoId;

  if (host.contains('youtube.com') || host.contains('youtube-nocookie.com')) {
    videoId = uri.queryParameters['v'];

    if ((videoId == null || videoId.isEmpty) && uri.pathSegments.isNotEmpty) {
      final embedIndex = uri.pathSegments.indexOf('embed');
      if (embedIndex != -1 && embedIndex + 1 < uri.pathSegments.length) {
        videoId = uri.pathSegments[embedIndex + 1];
      }
    }
  } else if (host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
    videoId = uri.pathSegments.first;
  }

  if (videoId == null || videoId.isEmpty) {
    return null;
  }

  return Uri.https('www.youtube.com', '/embed/$videoId', {
    'autoplay': '1',
    'playsinline': '1',
    'rel': '0',
  });
}

Uri? _buildVimeoEmbedUri(Uri uri) {
  final host = uri.host.toLowerCase();
  if (!host.contains('vimeo.com')) {
    return null;
  }

  String? idSegment;
  for (final segment in uri.pathSegments.reversed) {
    if (segment.isNotEmpty) {
      idSegment = segment;
      break;
    }
  }

  if (idSegment == null || int.tryParse(idSegment) == null) {
    return null;
  }

  return Uri.https('player.vimeo.com', '/video/$idSegment', {'autoplay': '1'});
}

String? _buildYoutubeThumbnail(Uri? uri) {
  if (uri == null) {
    return null;
  }

  final embedUri = _buildYoutubeEmbedUri(uri);
  if (embedUri == null || embedUri.pathSegments.isEmpty) {
    return null;
  }

  final videoId = embedUri.pathSegments.last;
  if (videoId.isEmpty) {
    return null;
  }

  return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
}

void _showLaunchError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Unable to open the APOD video right now.')),
  );
}
