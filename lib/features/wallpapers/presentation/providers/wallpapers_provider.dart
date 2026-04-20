import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/wallpapers_firestore_data_source.dart';
import '../../domain/wallpaper_entity.dart';

final wallpapersProvider = FutureProvider.autoDispose<List<WallpaperEntity>>((
  ref,
) async {
  final models = await ref
      .watch(wallpapersFirestoreDataSourceProvider)
      .fetchWallpapers();

  return models.map((m) => m.toEntity()).toList(growable: false);
});
