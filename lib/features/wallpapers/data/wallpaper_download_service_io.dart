import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';

class WallpaperDownloadResult {
  const WallpaperDownloadResult({required this.message});

  final String message;
}

class WallpaperDownloadService {
  const WallpaperDownloadService();

  Future<WallpaperDownloadResult> download({
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
