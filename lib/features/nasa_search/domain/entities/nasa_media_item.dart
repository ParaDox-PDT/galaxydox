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
  final DateTime? dateCreated;
  final String? photographer;
  final String? secondaryCreator;
  final List<String> keywords;

  bool get hasKeywords => keywords.isNotEmpty;
}
