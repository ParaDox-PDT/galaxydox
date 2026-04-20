import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/wallpaper_model.dart';

final wallpapersFirestoreDataSourceProvider =
    Provider<WallpapersFirestoreDataSource>(
      (ref) => WallpapersFirestoreDataSourceImpl(FirebaseFirestore.instance),
    );

abstract interface class WallpapersFirestoreDataSource {
  Future<List<WallpaperModel>> fetchWallpapers();
}

class WallpapersFirestoreDataSourceImpl
    implements WallpapersFirestoreDataSource {
  WallpapersFirestoreDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('wallpapers');

  @override
  Future<List<WallpaperModel>> fetchWallpapers() async {
    try {
      final snapshot = await _collection.get();
      final wallpapers = snapshot.docs
          .map(WallpaperModel.fromDocument)
          .toList(growable: false);
      wallpapers.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      return wallpapers;
    } catch (error, stackTrace) {
      _throwMappedError(error, stackTrace);
    }
  }

  Never _throwMappedError(Object error, StackTrace stackTrace) {
    if (error is AppException) throw error;

    if (error is FirebaseException) {
      throw AppException(
        type: AppExceptionType.network,
        message: 'Wallpaper data could not be loaded right now.',
        cause: error,
      );
    }

    throw AppException(
      type: AppExceptionType.unknown,
      message: 'An unexpected error occurred while loading wallpapers.',
      cause: error,
    );
  }
}
