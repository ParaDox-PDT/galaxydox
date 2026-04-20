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
    throw const AppException(
      type: AppExceptionType.unknown,
      message: 'Wallpaper downloads are not supported on this platform.',
    );
  }
}
