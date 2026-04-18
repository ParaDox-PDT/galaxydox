// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:indexed_db' as idb;
import 'dart:typed_data';

import '../../../core/errors/app_exception.dart';
import 'models/resolved_planet_model.dart';

class PlanetModelCacheService {
  const PlanetModelCacheService();

  static const _dbName = 'galaxydox_planet_models';
  static const _storeName = 'models';
  static const _dbVersion = 1;

  Future<ResolvedPlanetModel> prepareModel({
    required String planetId,
    required String modelUrl,
    void Function(double? progress)? onDownloadProgress,
  }) async {
    final trimmedUrl = modelUrl.trim();
    if (trimmedUrl.isEmpty) {
      throw const AppException(
        type: AppExceptionType.serialization,
        message: 'This planet does not have a valid 3D model URL.',
      );
    }

    final modelUri = Uri.tryParse(trimmedUrl);
    if (modelUri == null || !modelUri.hasScheme) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Invalid 3D model URL: $trimmedUrl',
      );
    }

    final cacheKey = _buildCacheKey(planetId: planetId, modelUri: modelUri);
    final db = await _openDatabase();

    try {
      final cachedBytes = await _getFromCache(db, cacheKey);
      if (cachedBytes != null) {
        onDownloadProgress?.call(1);
        return ResolvedPlanetModel(
          viewerSrc: _createBlobUrl(cachedBytes),
          isStoredLocally: true,
          wasLoadedFromCache: true,
        );
      }

      onDownloadProgress?.call(0);
      final bytes = await _downloadBytes(
        uri: modelUri,
        onProgress: onDownloadProgress,
      );

      await _saveToCache(db, cacheKey, bytes);
      onDownloadProgress?.call(1);

      return ResolvedPlanetModel(
        viewerSrc: _createBlobUrl(bytes),
        isStoredLocally: true,
        wasLoadedFromCache: false,
      );
    } finally {
      db.close();
    }
  }

  Future<idb.Database> _openDatabase() {
    return html.window.indexedDB!.open(
      _dbName,
      version: _dbVersion,
      onUpgradeNeeded: (idb.VersionChangeEvent event) {
        // ignore: avoid_dynamic_calls
        final db = (event.target as dynamic).result as idb.Database;
        final names = db.objectStoreNames;
        if (names == null || !names.contains(_storeName)) {
          db.createObjectStore(_storeName);
        }
      },
    );
  }

  Future<Uint8List?> _getFromCache(idb.Database db, String key) async {
    final txn = db.transaction(_storeName, 'readonly');
    final store = txn.objectStore(_storeName);
    final result = await store.getObject(key);
    await txn.completed;
    if (result == null) return null;
    if (result is ByteBuffer) return result.asUint8List();
    return null;
  }

  Future<void> _saveToCache(
    idb.Database db,
    String key,
    Uint8List bytes,
  ) async {
    final txn = db.transaction(_storeName, 'readwrite');
    final store = txn.objectStore(_storeName);
    await store.put(bytes.buffer, key);
    await txn.completed;
  }

  Future<Uint8List> _downloadBytes({
    required Uri uri,
    void Function(double? progress)? onProgress,
  }) async {
    final completer = Completer<Uint8List>();
    final request = html.HttpRequest();
    request.open('GET', uri.toString());
    request.responseType = 'arraybuffer';

    request.onProgress.listen((event) {
      final loaded = event.loaded;
      final total = event.total;
      if (loaded != null && total != null && total > 0) {
        onProgress?.call(loaded / total);
      } else {
        onProgress?.call(null);
      }
    });

    request.onLoad.listen((_) {
      if (request.status == 200) {
        final buffer = request.response as ByteBuffer;
        completer.complete(buffer.asUint8List());
      } else {
        completer.completeError(
          AppException(
            type: AppExceptionType.network,
            message:
                '3D model could not be downloaded (HTTP ${request.status}).',
          ),
        );
      }
    });

    request.onError.listen((_) {
      completer.completeError(
        const AppException(
          type: AppExceptionType.network,
          message: '3D model could not be downloaded from Firebase.',
        ),
      );
    });

    request.send();

    try {
      return await completer.future;
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        type: AppExceptionType.network,
        message: '3D model could not be downloaded from Firebase.',
        cause: error,
      );
    }
  }

  String _createBlobUrl(Uint8List bytes) {
    final blob = html.Blob([bytes.buffer], 'model/gltf-binary');
    return html.Url.createObjectUrl(blob);
  }

  String _buildCacheKey({
    required String planetId,
    required Uri modelUri,
  }) {
    final safePlanetId = _sanitizeToken(planetId);
    final encodedUrl = base64Url
        .encode(utf8.encode(modelUri.toString()))
        .replaceAll('=', '');
    return '${safePlanetId}_$encodedUrl';
  }

  String _sanitizeToken(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
