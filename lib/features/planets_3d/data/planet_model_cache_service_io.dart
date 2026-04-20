import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import 'local_model_server.dart';
import 'models/resolved_planet_model.dart';

class PlanetModelCacheService {
  const PlanetModelCacheService();

  static const _modelsDirectoryName = 'planet_models';

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

    final directory = await _ensureModelsDirectory();
    final fileName = _buildFileName(planetId: planetId, modelUri: modelUri);
    final targetFile = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );

    await _deleteStaleFiles(
      directory: directory,
      planetId: planetId,
      currentFileName: fileName,
    );

    final exists = await targetFile.exists();
    if (!exists) {
      onDownloadProgress?.call(0);
      await _downloadFile(
        sourceUri: modelUri,
        targetFile: targetFile,
        onDownloadProgress: onDownloadProgress,
      );
    } else {
      onDownloadProgress?.call(1);
    }

    final viewerSrc = await LocalModelServer.instance.serveFile(
      targetFile.path,
    );
    return ResolvedPlanetModel(
      viewerSrc: viewerSrc,
      isStoredLocally: true,
      wasLoadedFromCache: exists,
      localFilePath: targetFile.path,
    );
  }

  Future<Directory> _ensureModelsDirectory() async {
    try {
      final supportDirectory = await getApplicationSupportDirectory();
      final modelsDirectory = Directory(
        '${supportDirectory.path}${Platform.pathSeparator}$_modelsDirectoryName',
      );

      if (!await modelsDirectory.exists()) {
        await modelsDirectory.create(recursive: true);
      }

      return modelsDirectory;
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Device storage for 3D models could not be prepared.',
        cause: error,
      );
    }
  }

  Future<void> _downloadFile({
    required Uri sourceUri,
    required File targetFile,
    void Function(double? progress)? onDownloadProgress,
  }) async {
    final tempFile = File('${targetFile.path}.download');

    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final dio = Dio();
      await dio.downloadUri(
        sourceUri,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            onDownloadProgress?.call(null);
            return;
          }

          onDownloadProgress?.call(received / total);
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      await tempFile.rename(targetFile.path);
      onDownloadProgress?.call(1);
    } on DioException catch (error) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      throw AppException(
        type: AppExceptionType.network,
        message: '3D model could not be downloaded from Firebase.',
        cause: error,
      );
    } catch (error) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      throw AppException(
        type: AppExceptionType.storage,
        message: 'Downloaded 3D model could not be saved on this device.',
        cause: error,
      );
    }
  }

  Future<void> _deleteStaleFiles({
    required Directory directory,
    required String planetId,
    required String currentFileName,
  }) async {
    final prefix = '${_sanitizeToken(planetId)}_';

    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }

      final name = entity.uri.pathSegments.last;
      if (name.startsWith(prefix) && name != currentFileName) {
        try {
          await entity.delete();
        } catch (_) {
          // Best-effort cleanup only.
        }
      }
    }
  }

  String _buildFileName({required String planetId, required Uri modelUri}) {
    final safePlanetId = _sanitizeToken(planetId);
    final encodedUrl = base64Url
        .encode(utf8.encode(modelUri.toString()))
        .replaceAll('=', '');
    final extension = _resolveExtension(modelUri);

    return '${safePlanetId}_$encodedUrl$extension';
  }

  String _sanitizeToken(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  String _resolveExtension(Uri modelUri) {
    final lastSegment = modelUri.pathSegments.isEmpty
        ? ''
        : modelUri.pathSegments.last;
    final dotIndex = lastSegment.lastIndexOf('.');
    if (dotIndex == -1) {
      return '.glb';
    }

    final extension = lastSegment.substring(dotIndex);
    return extension.isEmpty ? '.glb' : extension;
  }
}
