// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, uri_does_not_exist

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

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
    try {
      onProgress?.call(0);
      final bytes = await _downloadBytes(uri: imageUri, onProgress: onProgress);
      _triggerBrowserDownload(bytes: bytes, fileName: fileName);
      onProgress?.call(1);

      return const WallpaperDownloadResult(
        message: 'Download started in your browser',
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        type: AppExceptionType.network,
        message: 'Wallpaper could not be downloaded in the browser.',
        cause: error,
      );
    }
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
        final buffer = request.response;
        if (buffer is ByteBuffer) {
          completer.complete(buffer.asUint8List());
          return;
        }
      }

      completer.completeError(
        AppException(
          type: AppExceptionType.network,
          message:
              'Wallpaper could not be downloaded (HTTP ${request.status}).',
        ),
      );
    });

    request.onError.listen((_) {
      completer.completeError(
        const AppException(
          type: AppExceptionType.network,
          message: 'Wallpaper could not be downloaded in the browser.',
        ),
      );
    });

    request.send();
    return completer.future;
  }

  void _triggerBrowserDownload({
    required Uint8List bytes,
    required String fileName,
  }) {
    final blob = html.Blob([bytes], 'application/octet-stream');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: objectUrl)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(objectUrl);
  }
}
