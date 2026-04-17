import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/planet_model.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final planetsFirestoreDataSourceProvider = Provider<PlanetsFirestoreDataSource>(
  (ref) {
    return PlanetsFirestoreDataSourceImpl(ref.watch(firebaseFirestoreProvider));
  },
);

abstract interface class PlanetsFirestoreDataSource {
  Stream<List<PlanetModel>> watchPlanets();

  Stream<PlanetModel?> watchPlanet(String id);
}

class PlanetsFirestoreDataSourceImpl implements PlanetsFirestoreDataSource {
  PlanetsFirestoreDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('planets');

  @override
  Stream<List<PlanetModel>> watchPlanets() {
    return _collection
        .snapshots()
        .map((snapshot) {
          final planets = snapshot.docs
              .map(PlanetModel.fromDocument)
              .toList(growable: false);
          planets.sort((a, b) => a.index.compareTo(b.index));
          return planets;
        })
        .handleError(_mapStreamError);
  }

  @override
  Stream<PlanetModel?> watchPlanet(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }

          return PlanetModel.fromDocument(snapshot);
        })
        .handleError(_mapStreamError);
  }

  Never _mapStreamError(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      throw error;
    }

    if (error is FirebaseException) {
      throw AppException(
        type: AppExceptionType.network,
        message: 'Firebase planet data could not be loaded right now.',
        cause: error,
      );
    }

    throw AppException(
      type: AppExceptionType.unknown,
      message: 'An unexpected error occurred while loading planet data.',
      cause: error,
    );
  }
}
