import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/wallpaper_model.dart';

class WallpapersLocalDataSource {
  static const _boxName = 'wallpapers_cache';
  static const _cacheKey = 'list';

  Future<Box<dynamic>> get _box async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<dynamic>(_boxName);
    return Hive.openBox<dynamic>(_boxName);
  }

  Future<List<WallpaperModel>?> getCached() async {
    try {
      final box = await _box;
      final raw = box.get(_cacheKey);
      if (raw == null) return null;
      final list = raw as List;
      if (list.isEmpty) return null;
      return list
          .map((e) => WallpaperModel.fromMap(e as Map))
          .toList(growable: false);
    } catch (error) {
      debugPrint('WALLPAPERS CACHE READ ERROR: $error');
      return null;
    }
  }

  Future<void> save(List<WallpaperModel> models) async {
    try {
      final box = await _box;
      await box.put(_cacheKey, models.map((m) => m.toMap()).toList());
    } catch (error) {
      debugPrint('WALLPAPERS CACHE WRITE ERROR: $error');
    }
  }
}
