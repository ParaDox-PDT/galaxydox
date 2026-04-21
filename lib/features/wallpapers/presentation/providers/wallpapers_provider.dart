import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/wallpapers_firestore_data_source.dart';
import '../../data/datasources/wallpapers_local_data_source.dart';
import '../../domain/wallpaper_entity.dart';

final wallpapersProvider =
    AsyncNotifierProvider.autoDispose<
      WallpapersNotifier,
      List<WallpaperEntity>
    >(WallpapersNotifier.new);

final wallpaperByIdProvider = FutureProvider.autoDispose
    .family<WallpaperEntity?, String>((ref, id) async {
      final local = WallpapersLocalDataSource();
      final cached = await local.getById(id);
      if (cached != null) {
        return cached.toEntity();
      }

      final remote = ref.watch(wallpapersFirestoreDataSourceProvider);
      final fresh = await remote.fetchWallpaperById(id);
      if (fresh != null) {
        unawaited(local.upsert(fresh));
      }
      return fresh?.toEntity();
    });

class WallpapersNotifier extends AsyncNotifier<List<WallpaperEntity>> {
  late final WallpapersLocalDataSource _local;
  late final WallpapersFirestoreDataSource _remote;

  @override
  Future<List<WallpaperEntity>> build() async {
    _local = WallpapersLocalDataSource();
    _remote = ref.watch(wallpapersFirestoreDataSourceProvider);

    final cached = await _local.getCached();
    if (cached != null && cached.isNotEmpty) {
      // Serve cache immediately, refresh from Firebase in background.
      unawaited(Future<void>.microtask(_backgroundRefresh));
      return cached.map((m) => m.toEntity()).toList(growable: false);
    }

    // No cache – must wait for the first network fetch.
    return _fetchAndSave();
  }

  /// Silently fetches fresh data from Firebase and updates state.
  /// Called automatically after serving stale cache from [build].
  Future<void> _backgroundRefresh() async {
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } catch (_) {
      // Keep showing cached data; do not surface the error.
    }
  }

  /// Forces a visible loading state, fetches fresh data, and updates state.
  /// Used by pull-to-refresh and the manual Refresh button.
  Future<void> forceRefresh() async {
    state = const AsyncLoading();
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }

  Future<List<WallpaperEntity>> _fetchAndSave() async {
    final models = await _remote.fetchWallpapers();
    unawaited(_local.save(models));
    return models.map((m) => m.toEntity()).toList(growable: false);
  }
}
