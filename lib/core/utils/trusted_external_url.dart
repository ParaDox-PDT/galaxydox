import 'package:url_launcher/url_launcher.dart';

abstract final class TrustedHostSets {
  static const nasaHosts = {'nasa.gov'};
  static const nasaAndVideoHosts = {
    'nasa.gov',
    'youtube.com',
    'youtu.be',
    'img.youtube.com',
  };
}

Uri? sanitizeTrustedExternalUri(
  String rawUrl, {
  required Set<String> allowedHosts,
}) {
  final parsed = Uri.tryParse(rawUrl.trim());
  if (parsed == null || parsed.host.isEmpty) {
    return null;
  }

  final host = parsed.host.toLowerCase();
  final scheme = parsed.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') {
    return null;
  }

  final isTrusted = allowedHosts.any(
    (candidate) => host == candidate || host.endsWith('.$candidate'),
  );
  if (!isTrusted) {
    return null;
  }

  return parsed.replace(scheme: 'https');
}

Future<bool> launchExternalUri(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
