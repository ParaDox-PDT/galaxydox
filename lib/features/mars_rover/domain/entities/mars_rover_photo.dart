enum MarsRoverName {
  curiosity('curiosity', 'Curiosity'),
  opportunity('opportunity', 'Opportunity'),
  spirit('spirit', 'Spirit'),
  perseverance('perseverance', 'Perseverance');

  const MarsRoverName(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum MarsRoverFilterMode { earthDate, sol }

class MarsRoverPhoto {
  const MarsRoverPhoto({
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
}
