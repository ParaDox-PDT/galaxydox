import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/nasa_search_repository_impl.dart';
import '../../domain/usecases/resolve_nasa_video_playback_url.dart';

final resolveNasaVideoPlaybackUrlUseCaseProvider =
    Provider<ResolveNasaVideoPlaybackUrlUseCase>((ref) {
      return ResolveNasaVideoPlaybackUrlUseCase(
        ref.watch(nasaSearchRepositoryProvider),
      );
    });

final nasaVideoPlaybackUrlProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, manifestUrl) async {
      final useCase = ref.watch(resolveNasaVideoPlaybackUrlUseCaseProvider);
      final result = await useCase(assetManifestUrl: manifestUrl);

      return result.when(
        success: (playbackUrl) => playbackUrl,
        failure: (exception) => throw exception,
      );
    });
