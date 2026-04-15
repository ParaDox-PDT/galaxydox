import 'package:equatable/equatable.dart';

class EpicCoordinates extends Equatable {
  const EpicCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

class EpicJ2000Position extends Equatable {
  const EpicJ2000Position({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;

  @override
  List<Object?> get props => [x, y, z];
}

class EpicAttitudeQuaternions extends Equatable {
  const EpicAttitudeQuaternions({
    required this.q0,
    required this.q1,
    required this.q2,
    required this.q3,
  });

  final double q0;
  final double q1;
  final double q2;
  final double q3;

  @override
  List<Object?> get props => [q0, q1, q2, q3];
}

class EpicImage extends Equatable {
  const EpicImage({
    required this.identifier,
    required this.caption,
    required this.image,
    required this.date,
    required this.imageUrl,
    this.centroidCoordinates,
    this.dscovrJ2000Position,
    this.lunarJ2000Position,
    this.sunJ2000Position,
    this.attitudeQuaternions,
  });

  final String identifier;
  final String caption;
  final String image;
  final DateTime date;
  final String imageUrl;
  final EpicCoordinates? centroidCoordinates;
  final EpicJ2000Position? dscovrJ2000Position;
  final EpicJ2000Position? lunarJ2000Position;
  final EpicJ2000Position? sunJ2000Position;
  final EpicAttitudeQuaternions? attitudeQuaternions;

  bool get hasMetadata =>
      centroidCoordinates != null ||
      dscovrJ2000Position != null ||
      lunarJ2000Position != null ||
      sunJ2000Position != null ||
      attitudeQuaternions != null;

  @override
  List<Object?> get props => [
    identifier,
    caption,
    image,
    date,
    imageUrl,
    centroidCoordinates,
    dscovrJ2000Position,
    lunarJ2000Position,
    sunJ2000Position,
    attitudeQuaternions,
  ];
}
