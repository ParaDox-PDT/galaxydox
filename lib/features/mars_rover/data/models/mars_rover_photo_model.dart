import '../../domain/entities/mars_rover_photo.dart';

class MarsRoverPhotoModel {
  const MarsRoverPhotoModel({
    required this.id,
    required this.imageUrl,
    required this.earthDate,
    required this.sol,
    required this.cameraName,
    required this.cameraFullName,
    required this.roverName,
    required this.roverLandingDate,
    required this.roverLaunchDate,
    required this.roverStatus,
  });

  factory MarsRoverPhotoModel.fromJson(Map<String, dynamic> json) {
    final camera = json['camera'] as Map<String, dynamic>? ?? {};
    final rover = json['rover'] as Map<String, dynamic>? ?? {};

    return MarsRoverPhotoModel(
      id: json['id'] as int? ?? 0,
      imageUrl: json['img_src'] as String? ?? '',
      earthDate: DateTime.parse(json['earth_date'] as String),
      sol: json['sol'] as int? ?? 0,
      cameraName: camera['name'] as String? ?? '',
      cameraFullName: camera['full_name'] as String? ?? '',
      roverName: rover['name'] as String? ?? '',
      roverLandingDate: DateTime.parse(rover['landing_date'] as String),
      roverLaunchDate: DateTime.parse(rover['launch_date'] as String),
      roverStatus: rover['status'] as String? ?? '',
    );
  }

  final int id;
  final String imageUrl;
  final DateTime earthDate;
  final int sol;
  final String cameraName;
  final String cameraFullName;
  final String roverName;
  final DateTime roverLandingDate;
  final DateTime roverLaunchDate;
  final String roverStatus;

  MarsRoverPhoto toEntity() {
    return MarsRoverPhoto(
      id: id,
      imageUrl: imageUrl,
      earthDate: earthDate,
      sol: sol,
      cameraName: cameraName,
      cameraFullName: cameraFullName,
      roverName: roverName,
      roverLandingDate: roverLandingDate,
      roverLaunchDate: roverLaunchDate,
      roverStatus: roverStatus,
    );
  }
}
