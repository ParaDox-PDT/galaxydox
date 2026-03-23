class NearEarthObject {
  const NearEarthObject({
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

  double get averageDiameterMeters =>
      (minDiameterMeters + maxDiameterMeters) / 2;
}
