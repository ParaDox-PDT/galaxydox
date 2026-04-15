import 'package:flutter/material.dart';

import '../domain/planet_entity.dart';

abstract final class PlanetsCatalog {
  static const List<PlanetEntity> planets = [
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
    // ─── Add more planets below ────────────────────────────────
    // PlanetEntity(
    //   id: 'mars',
    //   title: 'Mars',
    //   subtitle: 'The Red Planet',
    //   description: 'Mars is the fourth planet from the Sun...',
    //   modelAssetPath: 'assets/3d_models/mars.glb',
    //   thumbnailAssetPath: 'assets/images/planets.png',
    //   accentColor: Color(0xFFFF9E6D),
    //   facts: [...],
    // ),
  ];
}
