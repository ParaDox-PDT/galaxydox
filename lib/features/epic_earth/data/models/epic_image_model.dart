import '../../domain/entities/epic_image.dart';
import '../mappers/epic_image_url_builder.dart';

class EpicImageModel extends EpicImage {
  const EpicImageModel({
    required super.identifier,
    required super.caption,
    required super.image,
    required super.date,
    required super.imageUrl,
    super.centroidCoordinates,
    super.dscovrJ2000Position,
    super.lunarJ2000Position,
    super.sunJ2000Position,
    super.attitudeQuaternions,
  });

  factory EpicImageModel.fromJson(Map<String, dynamic> json) {
    final imageName = (json['image'] as String? ?? '').trim();
    if (imageName.isEmpty) {
      throw const FormatException('EPIC image metadata is missing image id.');
    }

    final parsedDate = _parseDate(json['date']);
    final imageUrl =
        json['imageUrl'] as String? ??
        EpicImageUrlBuilder.build(date: parsedDate, imageName: imageName);

    return EpicImageModel(
      identifier: (json['identifier'] as String? ?? imageName).trim(),
      caption: (json['caption'] as String? ?? '').trim(),
      image: imageName,
      date: parsedDate,
      imageUrl: imageUrl,
      centroidCoordinates: _parseCoordinates(json['centroid_coordinates']),
      dscovrJ2000Position: _parsePosition(json['dscovr_j2000_position']),
      lunarJ2000Position: _parsePosition(json['lunar_j2000_position']),
      sunJ2000Position: _parsePosition(json['sun_j2000_position']),
      attitudeQuaternions: _parseQuaternions(json['attitude_quaternions']),
    );
  }

  EpicImage toEntity() {
    return EpicImage(
      identifier: identifier,
      caption: caption,
      image: image,
      date: date,
      imageUrl: imageUrl,
      centroidCoordinates: centroidCoordinates,
      dscovrJ2000Position: dscovrJ2000Position,
      lunarJ2000Position: lunarJ2000Position,
      sunJ2000Position: sunJ2000Position,
      attitudeQuaternions: attitudeQuaternions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'caption': caption,
      'image': image,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      if (centroidCoordinates != null)
        'centroid_coordinates': _coordinatesToJson(centroidCoordinates!),
      if (dscovrJ2000Position != null)
        'dscovr_j2000_position': _positionToJson(dscovrJ2000Position!),
      if (lunarJ2000Position != null)
        'lunar_j2000_position': _positionToJson(lunarJ2000Position!),
      if (sunJ2000Position != null)
        'sun_j2000_position': _positionToJson(sunJ2000Position!),
      if (attitudeQuaternions != null)
        'attitude_quaternions': _quaternionsToJson(attitudeQuaternions!),
    };
  }

  static DateTime _parseDate(Object? value) {
    final raw = value as String?;
    if (raw == null || raw.trim().isEmpty) {
      throw const FormatException('EPIC image metadata is missing date.');
    }

    final normalized = raw.trim().replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      throw FormatException('Invalid EPIC image date: $raw');
    }

    return parsed;
  }

  static EpicCoordinates? _parseCoordinates(Object? value) {
    if (value is! Map) {
      return null;
    }

    final latitude = _asDouble(value['lat']);
    final longitude = _asDouble(value['lon']);
    if (latitude == null || longitude == null) {
      return null;
    }

    return EpicCoordinates(latitude: latitude, longitude: longitude);
  }

  static EpicJ2000Position? _parsePosition(Object? value) {
    if (value is! Map) {
      return null;
    }

    final x = _asDouble(value['x']);
    final y = _asDouble(value['y']);
    final z = _asDouble(value['z']);
    if (x == null || y == null || z == null) {
      return null;
    }

    return EpicJ2000Position(x: x, y: y, z: z);
  }

  static EpicAttitudeQuaternions? _parseQuaternions(Object? value) {
    if (value is! Map) {
      return null;
    }

    final q0 = _asDouble(value['q0']);
    final q1 = _asDouble(value['q1']);
    final q2 = _asDouble(value['q2']);
    final q3 = _asDouble(value['q3']);
    if (q0 == null || q1 == null || q2 == null || q3 == null) {
      return null;
    }

    return EpicAttitudeQuaternions(q0: q0, q1: q1, q2: q2, q3: q3);
  }

  static double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  static Map<String, dynamic> _coordinatesToJson(EpicCoordinates value) {
    return {'lat': value.latitude, 'lon': value.longitude};
  }

  static Map<String, dynamic> _positionToJson(EpicJ2000Position value) {
    return {'x': value.x, 'y': value.y, 'z': value.z};
  }

  static Map<String, dynamic> _quaternionsToJson(
    EpicAttitudeQuaternions value,
  ) {
    return {'q0': value.q0, 'q1': value.q1, 'q2': value.q2, 'q3': value.q3};
  }
}
