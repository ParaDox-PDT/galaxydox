import '../../domain/entities/nasa_media_item.dart';

class NasaMediaItemModel {
  const NasaMediaItemModel({
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

  factory NasaMediaItemModel.fromJson(Map<String, dynamic> json) {
    final dataEntries = json['data'] as List<dynamic>? ?? const [];
    final links = json['links'] as List<dynamic>? ?? const [];
    final data = dataEntries.isNotEmpty
        ? dataEntries.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final link = links.isNotEmpty
        ? links.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final rawKeywords = data['keywords'] as List<dynamic>? ?? const [];

    return NasaMediaItemModel(
      nasaId: data['nasa_id'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled NASA media',
      description: data['description'] as String? ?? '',
      previewUrl: link['href'] as String? ?? '',
      mediaType: data['media_type'] as String? ?? '',
      center: data['center'] as String? ?? 'NASA',
      assetManifestUrl: json['href'] as String?,
      dateCreated: _parseDate(data['date_created'] as String?),
      photographer: data['photographer'] as String?,
      secondaryCreator: data['secondary_creator'] as String?,
      keywords: rawKeywords.map((item) => item.toString()).toList(),
    );
  }

  final String nasaId;
  final String title;
  final String description;
  final String previewUrl;
  final String mediaType;
  final String center;
  final String? assetManifestUrl;
  final DateTime? dateCreated;
  final String? photographer;
  final String? secondaryCreator;
  final List<String> keywords;

  NasaMediaItem toEntity() {
    return NasaMediaItem(
      nasaId: nasaId,
      title: title,
      description: description,
      previewUrl: previewUrl,
      mediaType: NasaMediaType.fromValue(mediaType),
      center: center,
      assetManifestUrl: assetManifestUrl,
      dateCreated: dateCreated,
      photographer: photographer,
      secondaryCreator: secondaryCreator,
      keywords: keywords,
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
