import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/nasa_media_item.dart';
import '../../domain/repositories/nasa_search_repository.dart';
import '../datasources/nasa_search_remote_data_source.dart';

final nasaSearchRepositoryProvider = Provider<NasaSearchRepository>((ref) {
  return NasaSearchRepositoryImpl(
    remoteDataSource: ref.watch(nasaSearchRemoteDataSourceProvider),
  );
});

class NasaSearchRepositoryImpl implements NasaSearchRepository {
  const NasaSearchRepositoryImpl({
    required NasaSearchRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NasaSearchRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<NasaMediaItem>>> search({
    required String query,
    required String mediaType,
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.search(
        query: query,
        mediaType: mediaType,
        page: page,
      );
      return Success(models.map((model) => model.toEntity()).toList());
    } on AppException catch (error) {
      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while building NASA search results.',
          cause: error,
        ),
      );
    }
  }
}
