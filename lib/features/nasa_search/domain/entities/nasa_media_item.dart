enum NasaMediaType {
  image,
  video,
  audio,
  unknown;

  static NasaMediaType fromValue(String value) {
    return switch (value.toLowerCase()) {
      'image' => NasaMediaType.image,
      'video' => NasaMediaType.video,
      'audio' => NasaMediaType.audio,
      _ => NasaMediaType.unknown,
    };
  }
}

class NasaMediaItem {
  const NasaMediaItem({
    required this.nasaId,
    required this.title,
    required this.description,
    required this.previewUrl,
    required this.mediaType,
    required this.center,
    this.assetManifestUrl,
    this.dateCreated,
    this.photographer,
    this.secondaryCreator,
    this.keywords = const [],
  });

  final String nasaId;
  final String title;
  final String description;
  final String previewUrl;
  final NasaMediaType mediaType;
  final String center;
  final String? assetManifestUrl;
  final DateTime? dateCreated;
  final String? photographer;
  final String? secondaryCreator;
  final List<String> keywords;

  bool get hasKeywords => keywords.isNotEmpty;
  bool get isVideo => mediaType == NasaMediaType.video;

  String? get resolvedAssetManifestUrl {
    final explicitUrl = assetManifestUrl?.trim();
    if (explicitUrl != null && explicitUrl.isNotEmpty) {
      return _normalizeHttpsUrl(explicitUrl);
    }

    if (!isVideo || previewUrl.trim().isEmpty) {
      return null;
    }

    final previewUri = Uri.tryParse(previewUrl);
    if (previewUri == null || previewUri.pathSegments.length < 2) {
      return null;
    }

    return previewUri
        .replace(
          scheme: 'https',
          pathSegments: [
            ...previewUri.pathSegments.take(previewUri.pathSegments.length - 1),
            'collection.json',
          ],
        )
        .toString();
  }
}

String _normalizeHttpsUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return value;
  }

  return uri.scheme.toLowerCase() == 'http'
      ? uri.replace(scheme: 'https').toString()
      : uri.toString();
}
