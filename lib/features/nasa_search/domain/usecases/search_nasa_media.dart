import '../../../../core/errors/result.dart';
import '../entities/nasa_media_item.dart';
import '../repositories/nasa_search_repository.dart';

class SearchNasaMediaUseCase {
  const SearchNasaMediaUseCase(this._repository);

  final NasaSearchRepository _repository;

  Future<Result<List<NasaMediaItem>>> call({
    required String query,
    required String mediaType,
    int page = 1,
  }) {
    return _repository.search(query: query, mediaType: mediaType, page: page);
  }
}
