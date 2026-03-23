enum ApodMediaType {
  image,
  video,
  unknown;

  static ApodMediaType fromValue(String value) {
    return switch (value) {
      'image' => ApodMediaType.image,
      'video' => ApodMediaType.video,
      _ => ApodMediaType.unknown,
    };
  }
}

class ApodItem {
  const ApodItem({
    required this.date,
    required this.title,
    required this.explanation,
    required this.mediaType,
    required this.url,
    this.hdUrl,
    this.thumbnailUrl,
    this.copyright,
  });

  final DateTime date;
  final String title;
  final String explanation;
  final ApodMediaType mediaType;
  final String url;
  final String? hdUrl;
  final String? thumbnailUrl;
  final String? copyright;

  bool get isImage => mediaType == ApodMediaType.image;
  bool get isVideo => mediaType == ApodMediaType.video;
  bool get hasHdImage => (hdUrl ?? '').isNotEmpty;

  String get preferredImageUrl {
    if (hasHdImage) {
      return hdUrl!;
    }

    if ((thumbnailUrl ?? '').isNotEmpty) {
      return thumbnailUrl!;
    }

    return url;
  }
}
