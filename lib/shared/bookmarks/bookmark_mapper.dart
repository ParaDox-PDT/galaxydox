import 'dart:convert';

import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../features/apod/domain/entities/apod_item.dart';
import '../../features/mars_rover/domain/entities/mars_rover_photo.dart';
import '../../features/nasa_search/domain/entities/nasa_media_item.dart';
import '../../features/neo/domain/entities/near_earth_object.dart';
import 'data/models/bookmark_item.dart';

abstract final class BookmarkMapper {
  static BookmarkItem fromApod(ApodItem item) {
    return BookmarkItem(
      id: 'apod:${item.date.toIso8601String()}',
      title: item.title,
      description: item.explanation,
      imageUrl: item.preferredImageUrl,
      contentType: BookmarkContentType.apod,
      payloadJson: jsonEncode({
        'date': item.date.toIso8601String(),
        'title': item.title,
        'explanation': item.explanation,
        'mediaType': item.mediaType.name,
        'url': item.url,
        'hdUrl': item.hdUrl,
        'thumbnailUrl': item.thumbnailUrl,
        'copyright': item.copyright,
      }),
      savedAt: DateTime.now(),
      subtitle: 'Astronomy Picture of the Day',
      metadataPrimary: item.isVideo ? 'Video' : 'Image',
      metadataSecondary: DateFormat.yMMMd().format(item.date),
      date: item.date,
    );
  }

  static BookmarkItem fromMarsRoverPhoto(MarsRoverPhoto photo) {
    return BookmarkItem(
      id: 'mars:${photo.id}',
      title: '${photo.roverName} • ${photo.cameraFullName}',
      description:
          'Captured on ${DateFormat.yMMMMd().format(photo.earthDate)} during sol ${photo.sol}. Rover status: ${photo.roverStatus}.',
      imageUrl: photo.imageUrl,
      contentType: BookmarkContentType.marsRover,
      payloadJson: jsonEncode({
        'id': photo.id,
        'imageUrl': photo.imageUrl,
        'earthDate': photo.earthDate.toIso8601String(),
        'sol': photo.sol,
        'cameraName': photo.cameraName,
        'cameraFullName': photo.cameraFullName,
        'roverName': photo.roverName,
        'roverLandingDate': photo.roverLandingDate.toIso8601String(),
        'roverLaunchDate': photo.roverLaunchDate.toIso8601String(),
        'roverStatus': photo.roverStatus,
      }),
      savedAt: DateTime.now(),
      subtitle: photo.cameraName,
      metadataPrimary: photo.roverName,
      metadataSecondary: 'Sol ${photo.sol}',
      date: photo.earthDate,
    );
  }

  static BookmarkItem fromNasaMediaItem(NasaMediaItem item) {
    return BookmarkItem(
      id: 'search:${item.nasaId}',
      title: item.title,
      description: item.description,
      imageUrl: item.previewUrl,
      contentType: BookmarkContentType.nasaMedia,
      payloadJson: jsonEncode({
        'nasaId': item.nasaId,
        'title': item.title,
        'description': item.description,
        'previewUrl': item.previewUrl,
        'mediaType': item.mediaType.name,
        'center': item.center,
        'assetManifestUrl': item.assetManifestUrl,
        'dateCreated': item.dateCreated?.toIso8601String(),
        'photographer': item.photographer,
        'secondaryCreator': item.secondaryCreator,
        'keywords': item.keywords,
      }),
      savedAt: DateTime.now(),
      subtitle: item.center,
      metadataPrimary: _nasaMediaLabel(item.mediaType),
      metadataSecondary: item.dateCreated == null
          ? null
          : DateFormat.yMMMd().format(item.dateCreated!),
      date: item.dateCreated,
    );
  }

  static BookmarkItem fromNearEarthObject(NearEarthObject object) {
    return BookmarkItem(
      id: 'neo:${object.id}:${object.closeApproachDate.toIso8601String()}',
      title: object.name,
      description:
          'Approaches ${object.orbitingBody} on ${DateFormat.yMMMMd().format(object.closeApproachDate)} at ${object.relativeVelocityKilometersPerSecond.toStringAsFixed(2)} km/s with a miss distance of ${NumberFormat.compact(locale: 'en_US').format(object.missDistanceKilometers)} km.',
      imageUrl: AppConstants.neoPreviewImage,
      contentType: BookmarkContentType.nearEarthObject,
      payloadJson: jsonEncode({
        'id': object.id,
        'name': object.name,
        'closeApproachDate': object.closeApproachDate.toIso8601String(),
        'isHazardous': object.isHazardous,
        'minDiameterMeters': object.minDiameterMeters,
        'maxDiameterMeters': object.maxDiameterMeters,
        'relativeVelocityKilometersPerSecond':
            object.relativeVelocityKilometersPerSecond,
        'missDistanceKilometers': object.missDistanceKilometers,
        'orbitingBody': object.orbitingBody,
        'nasaJplUrl': object.nasaJplUrl,
      }),
      savedAt: DateTime.now(),
      subtitle: object.isHazardous
          ? 'Potentially hazardous'
          : 'Low hazard profile',
      metadataPrimary: object.orbitingBody,
      metadataSecondary: DateFormat.yMMMd().format(object.closeApproachDate),
      date: object.closeApproachDate,
    );
  }

  static ApodItem toApod(BookmarkItem bookmark) {
    final payload = _decode(bookmark);
    return ApodItem(
      date: DateTime.parse(payload['date'] as String),
      title: payload['title'] as String,
      explanation: payload['explanation'] as String,
      mediaType: ApodMediaType.fromValue(payload['mediaType'] as String),
      url: payload['url'] as String,
      hdUrl: payload['hdUrl'] as String?,
      thumbnailUrl: payload['thumbnailUrl'] as String?,
      copyright: payload['copyright'] as String?,
    );
  }

  static MarsRoverPhoto toMarsRoverPhoto(BookmarkItem bookmark) {
    final payload = _decode(bookmark);
    return MarsRoverPhoto(
      id: payload['id'] as int,
      imageUrl: payload['imageUrl'] as String,
      earthDate: DateTime.parse(payload['earthDate'] as String),
      sol: payload['sol'] as int,
      cameraName: payload['cameraName'] as String,
      cameraFullName: payload['cameraFullName'] as String,
      roverName: payload['roverName'] as String,
      roverLandingDate: DateTime.parse(payload['roverLandingDate'] as String),
      roverLaunchDate: DateTime.parse(payload['roverLaunchDate'] as String),
      roverStatus: payload['roverStatus'] as String,
    );
  }

  static NasaMediaItem toNasaMediaItem(BookmarkItem bookmark) {
    final payload = _decode(bookmark);
    final rawKeywords = payload['keywords'] as List<dynamic>? ?? const [];

    return NasaMediaItem(
      nasaId: payload['nasaId'] as String,
      title: payload['title'] as String,
      description: payload['description'] as String,
      previewUrl: payload['previewUrl'] as String,
      mediaType: NasaMediaType.fromValue(payload['mediaType'] as String),
      center: payload['center'] as String,
      assetManifestUrl: payload['assetManifestUrl'] as String?,
      dateCreated: payload['dateCreated'] == null
          ? null
          : DateTime.parse(payload['dateCreated'] as String),
      photographer: payload['photographer'] as String?,
      secondaryCreator: payload['secondaryCreator'] as String?,
      keywords: rawKeywords.map((keyword) => keyword as String).toList(),
    );
  }

  static NearEarthObject toNearEarthObject(BookmarkItem bookmark) {
    final payload = _decode(bookmark);
    return NearEarthObject(
      id: payload['id'] as String,
      name: payload['name'] as String,
      closeApproachDate: DateTime.parse(payload['closeApproachDate'] as String),
      isHazardous: payload['isHazardous'] as bool,
      minDiameterMeters: (payload['minDiameterMeters'] as num).toDouble(),
      maxDiameterMeters: (payload['maxDiameterMeters'] as num).toDouble(),
      relativeVelocityKilometersPerSecond:
          (payload['relativeVelocityKilometersPerSecond'] as num).toDouble(),
      missDistanceKilometers: (payload['missDistanceKilometers'] as num)
          .toDouble(),
      orbitingBody: payload['orbitingBody'] as String,
      nasaJplUrl: payload['nasaJplUrl'] as String,
    );
  }

  static Map<String, dynamic> _decode(BookmarkItem bookmark) {
    return jsonDecode(bookmark.payloadJson) as Map<String, dynamic>;
  }

  static String _nasaMediaLabel(NasaMediaType type) {
    return switch (type) {
      NasaMediaType.image => 'Image',
      NasaMediaType.video => 'Video',
      NasaMediaType.audio => 'Audio',
      NasaMediaType.unknown => 'Media',
    };
  }
}
