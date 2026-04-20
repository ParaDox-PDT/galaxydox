import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/planets_firestore_data_source.dart';
import '../../data/planet_model_cache_service.dart';
import '../../domain/planet_entity.dart';

final planetModelCacheServiceProvider = Provider<PlanetModelCacheService>((
  ref,
) {
  return const PlanetModelCacheService();
});

final planetsProvider = StreamProvider.autoDispose<List<PlanetEntity>>((ref) {
  return ref
      .watch(planetsFirestoreDataSourceProvider)
      .watchPlanets()
      .map(
        (planets) => planets
            .where(_isPlanetVisibleOnCurrentPlatform)
            .toList(growable: false),
      );
});

final planetProvider = StreamProvider.autoDispose.family<PlanetEntity?, String>(
  (ref, id) {
    return ref
        .watch(planetsFirestoreDataSourceProvider)
        .watchPlanet(id)
        .map(
          (planet) =>
              planet != null && _isPlanetVisibleOnCurrentPlatform(planet)
              ? planet
              : null,
        );
  },
);

bool _isPlanetVisibleOnCurrentPlatform(PlanetEntity planet) {
  return kIsWeb || planet.forAllDevice;
}
