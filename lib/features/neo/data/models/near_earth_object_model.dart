import '../../domain/entities/near_earth_object.dart';

class NearEarthObjectModel {
  const NearEarthObjectModel({
    required this.id,
    required this.name,
    required this.closeApproachDate,
    required this.isHazardous,
    required this.minDiameterMeters,
    required this.maxDiameterMeters,
    required this.relativeVelocityKilometersPerSecond,
    required this.missDistanceKilometers,
    required this.orbitingBody,
    required this.nasaJplUrl,
  });

  factory NearEarthObjectModel.fromJson(
    Map<String, dynamic> json, {
    required String fallbackDate,
  }) {
    final diameter = json['estimated_diameter'] as Map<String, dynamic>? ?? {};
    final meters = diameter['meters'] as Map<String, dynamic>? ?? {};
    final approaches =
        json['close_approach_data'] as List<dynamic>? ?? const [];
    final approach = approaches.isNotEmpty
        ? approaches.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final relativeVelocity =
        approach['relative_velocity'] as Map<String, dynamic>? ?? {};
    final missDistance =
        approach['miss_distance'] as Map<String, dynamic>? ?? {};

    return NearEarthObjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown object',
      closeApproachDate: DateTime.parse(
        approach['close_approach_date'] as String? ?? fallbackDate,
      ),
      isHazardous: json['is_potentially_hazardous_asteroid'] as bool? ?? false,
      minDiameterMeters:
          (meters['estimated_diameter_min'] as num?)?.toDouble() ?? 0,
      maxDiameterMeters:
          (meters['estimated_diameter_max'] as num?)?.toDouble() ?? 0,
      relativeVelocityKilometersPerSecond:
          double.tryParse(
            relativeVelocity['kilometers_per_second'] as String? ?? '',
          ) ??
          0,
      missDistanceKilometers:
          double.tryParse(missDistance['kilometers'] as String? ?? '') ?? 0,
      orbitingBody: approach['orbiting_body'] as String? ?? 'Earth',
      nasaJplUrl: json['nasa_jpl_url'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final DateTime closeApproachDate;
  final bool isHazardous;
  final double minDiameterMeters;
  final double maxDiameterMeters;
  final double relativeVelocityKilometersPerSecond;
  final double missDistanceKilometers;
  final String orbitingBody;
  final String nasaJplUrl;

  NearEarthObject toEntity() {
    return NearEarthObject(
      id: id,
      name: name,
      closeApproachDate: closeApproachDate,
      isHazardous: isHazardous,
      minDiameterMeters: minDiameterMeters,
      maxDiameterMeters: maxDiameterMeters,
      relativeVelocityKilometersPerSecond: relativeVelocityKilometersPerSecond,
      missDistanceKilometers: missDistanceKilometers,
      orbitingBody: orbitingBody,
      nasaJplUrl: nasaJplUrl,
    );
  }
}
