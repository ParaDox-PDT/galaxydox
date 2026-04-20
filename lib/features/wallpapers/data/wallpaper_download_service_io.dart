import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';

class WallpaperDownloadResult {
  const WallpaperDownloadResult({required this.message});

  final String message;
}

class WallpaperDownloadService {
  const WallpaperDownloadService();

  static const MethodChannel _androidChannel = MethodChannel(
    'com.galaxydox.app/wallpaper_downloads',
  );

  Future<WallpaperDownloadResult> download({
    required Uri imageUri,
    required String fileName,
    void Function(double? progress)? onProgress,
  }) async {
    if (Platform.isAndroid) {
      return _downloadOnAndroid(
        imageUri: imageUri,
        fileName: fileName,
        onProgress: onProgress,
      );
    }

    return _downloadToFileSystem(
      imageUri: imageUri,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  Future<WallpaperDownloadResult> _downloadOnAndroid({
    required Uri imageUri,
    required String fileName,
    void Function(double? progress)? onProgress,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.getUri<List<int>>(
        imageUri,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            onProgress?.call(null);
            return;
          }

          onProgress?.call(received / total);
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const AppException(
          type: AppExceptionType.storage,
          message: 'Wallpaper file was empty after download.',
        );
      }

      await _androidChannel.invokeMethod<String>('saveImageToGallery', {
        'fileName': fileName,
        'mimeType': _resolveMimeType(fileName),
        'bytes': Uint8List.fromList(bytes),
      });

      onProgress?.call(1);
      return const WallpaperDownloadResult(
        message: 'Saved to Gallery in Pictures/GalaxyDox',
      );
    } on DioException catch (error) {
      throw AppException(
        type: AppExceptionType.network,
        message: 'Wallpaper could not be downloaded right now.',
        cause: error,
      );
    } on PlatformException catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Wallpaper could not be saved to your Gallery.',
        cause: error,
      );
    }
  }

  Future<WallpaperDownloadResult> _downloadToFileSystem({
    required Uri imageUri,
    required String fileName,
    void Function(double? progress)? onProgress,
  }) async {
    final directory = await _resolveDirectory();
    final targetFile = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );
    final tempFile = File('${targetFile.path}.download');

    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final dio = Dio();
      await dio.downloadUri(
        imageUri,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            onProgress?.call(null);
            return;
          }

          onProgress?.call(received / total);
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      await tempFile.rename(targetFile.path);
      onProgress?.call(1);

      final savedToDownloads = await _isDownloadsDirectory(directory);
      return WallpaperDownloadResult(
        message: savedToDownloads
            ? 'Saved to Downloads'
            : 'Saved on this device',
      );
    } on DioException catch (error) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      throw AppException(
        type: AppExceptionType.network,
        message: 'Wallpaper could not be downloaded right now.',
        cause: error,
      );
    } catch (error) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (error is AppException) {
        rethrow;
      }

      throw AppException(
        type: AppExceptionType.storage,
        message: 'Wallpaper could not be saved on this device.',
        cause: error,
      );
    }
  }

  String _resolveMimeType(String fileName) {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';

    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'image/jpeg';
    }
  }

  Future<Directory> _resolveDirectory() async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory != null) {
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
        }
        return downloadsDirectory;
      }

      final documentsDirectory = await getApplicationDocumentsDirectory();
      if (!await documentsDirectory.exists()) {
        await documentsDirectory.create(recursive: true);
      }
      return documentsDirectory;
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Device storage could not be prepared for this download.',
        cause: error,
      );
    }
  }

  Future<bool> _isDownloadsDirectory(Directory directory) async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        return false;
      }

      return downloadsDirectory.path == directory.path;
    } catch (_) {
      return false;
    }
  }
}
