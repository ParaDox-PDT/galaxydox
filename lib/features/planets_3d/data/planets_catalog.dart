import 'package:flutter/material.dart';

import '../domain/planet_entity.dart';

abstract final class PlanetsCatalog {
  static const List<PlanetEntity> planets = [
    PlanetEntity(
      id: 'sun',
      title: 'Sun',
      subtitle: 'Our Star',
      description:
          'The Sun is the star at the center of the Solar System. It is a nearly perfect sphere of hot plasma, '
          'radiating energy mainly as visible light, ultraviolet light, and infrared radiation.',
      modelAssetPath: 'assets/3d_models/sun.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFFFFB300),
      facts: [
        'Diameter: 1.39M km',
        'Age: 4.6 Billion Years',
        'Surface temp: 5,505 °C',
        'Mass: 330,000 x Earth',
      ],
    ),
    PlanetEntity(
      id: 'mercury',
      title: 'Mercury',
      subtitle: 'The Swift Planet',
      description:
          'Mercury is the smallest planet in the Solar System and the closest to the Sun. '
          'Its orbit around the Sun takes 87.97 Earth days, the shortest of all the planets.',
      modelAssetPath: 'assets/3d_models/mercury.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFFB0BEC5),
      facts: [
        'Diameter: 4,880 km',
        'Distance from Sun: 57.9M km',
        'Orbital period: 88 days',
        'Surface gravity: 3.7 m/s²',
      ],
    ),
    PlanetEntity(
      id: 'venus',
      title: 'Venus',
      subtitle: 'The Morning Star',
      description:
          'Venus is the second planet from the Sun. It is sometimes called Earth\'s "sister" or "twin" planet '
          'as it is almost as large and has a similar composition, but has a toxic atmosphere.',
      modelAssetPath: 'assets/3d_models/venus.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFFFFCC80),
      facts: [
        'Diameter: 12,104 km',
        'Distance from Sun: 108.2M km',
        'Orbital period: 225 days',
        'Surface gravity: 8.87 m/s²',
      ],
    ),
    PlanetEntity(
      id: 'earth',
      title: 'Earth',
      subtitle: 'The Blue Marble',
      description:
          'Earth is the third planet from the Sun and the only known astronomical object to harbor life. '
          'Its surface is 71% water, with vast oceans shaping weather, climate, and the conditions for life.',
      modelAssetPath: 'assets/3d_models/earth.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFF58B9FF),
      facts: [
        'Diameter: 12,742 km',
        'Distance from Sun: 149.6M km',
        'Orbital period: 365.25 days',
        'Surface gravity: 9.807 m/s²',
      ],
    ),
    PlanetEntity(
      id: 'mars',
      title: 'Mars',
      subtitle: 'The Red Planet',
      description:
          'Mars is the fourth planet from the Sun. The reddish iron oxide prevalent on its surface '
          'gives it a reddish appearance that is distinctive among the astronomical bodies visible to the naked eye.',
      modelAssetPath: 'assets/3d_models/mars.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFFFF7043),
      facts: [
        'Diameter: 6,779 km',
        'Distance from Sun: 227.9M km',
        'Orbital period: 687 days',
        'Surface gravity: 3.721 m/s²',
      ],
    ),
    PlanetEntity(
      id: 'jupiter',
      title: 'Jupiter',
      subtitle: 'The Gas Giant',
      description:
          'Jupiter is the fifth planet from the Sun and the largest in the Solar System. It is a gas giant '
          'with a mass more than two and a half times that of all the other planets in the Solar System combined.',
      modelAssetPath: 'assets/3d_models/jupiter.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFFD4CCB6),
      facts: [
        'Diameter: 139,820 km',
        'Distance from Sun: 778.5M km',
        'Orbital period: 11.86 years',
        'Surface gravity: 24.79 m/s²',
      ],
    ),
    PlanetEntity(
      id: 'saturn',
      title: 'Saturn',
      subtitle: 'The Ringed Planet',
      description:
          'Saturn is the sixth planet from the Sun and the second-largest in the Solar System, after Jupiter. '
          'It is a gas giant with an average radius of about nine and a half times that of Earth.',
      modelAssetPath: 'assets/3d_models/saturn.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFFE6C79A),
      facts: [
        'Diameter: 116,460 km',
        'Distance from Sun: 1.43B km',
        'Orbital period: 29.5 years',
        'Surface gravity: 10.44 m/s²',
      ],
    ),
    PlanetEntity(
      id: 'neptune',
      title: 'Neptune',
      subtitle: 'The Ice Giant',
      description:
          'Neptune is the eighth and farthest-known Solar planet from the Sun. In the Solar System, '
          'it is the fourth-largest planet by diameter, the third-most-massive planet, and the densest giant planet.',
      modelAssetPath: 'assets/3d_models/neptun.glb',
      thumbnailAssetPath: 'assets/images/planets.png',
      accentColor: Color(0xFF4FC3F7),
      facts: [
        'Diameter: 49,244 km',
        'Distance from Sun: 4.5B km',
        'Orbital period: 165 years',
        'Surface gravity: 11.15 m/s²',
      ],
    ),
  ];
}
