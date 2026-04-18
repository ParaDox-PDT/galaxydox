import '../../domain/entities/apod_item.dart';

class ApodModel {
  const ApodModel({
    required this.date,
    required this.title,
    required this.explanation,
    required this.mediaType,
    required this.url,
    this.hdUrl,
    this.thumbnailUrl,
    this.copyright,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? '',
      url: json['url'] as String? ?? '',
      hdUrl: json['hdurl'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      copyright: json['copyright'] as String?,
    );
  }

  final DateTime date;
  final String title;
  final String explanation;
  final String mediaType;
  final String url;
  final String? hdUrl;
  final String? thumbnailUrl;
  final String? copyright;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T').first,
      'title': title,
      'explanation': explanation,
      'media_type': mediaType,
      'url': url,
      'hdurl': hdUrl,
      'thumbnail_url': thumbnailUrl,
      'copyright': copyright,
    };
  }

  ApodItem toEntity() {
    return ApodItem(
      date: date,
      title: title,
      explanation: explanation,
      mediaType: ApodMediaType.fromValue(mediaType),
      url: url,
      hdUrl: hdUrl,
      thumbnailUrl: thumbnailUrl,
      copyright: copyright,
    );
  }
}
