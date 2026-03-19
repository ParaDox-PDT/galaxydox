import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'dio_provider.dart';

final nasaApiClientProvider = Provider<NasaApiClient>((ref) {
  return NasaApiClient(
    apiDio: ref.watch(nasaApiDioProvider),
    mediaDio: ref.watch(nasaMediaDioProvider),
  );
});

class NasaApiClient {
  NasaApiClient({required Dio apiDio, required Dio mediaDio})
    : _apiDio = apiDio,
      _mediaDio = mediaDio;

  final Dio _apiDio;
  final Dio _mediaDio;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<Response<Map<String, dynamic>>> getApod({
    DateTime? date,
    bool hd = true,
  }) {
    return _apiDio.get<Map<String, dynamic>>(
      '/planetary/apod',
      queryParameters: {if (date != null) 'date': _formatDate(date), 'hd': hd},
    );
  }

  Future<Response<Map<String, dynamic>>> getMarsRoverPhotos({
    required String rover,
    int? sol,
    DateTime? earthDate,
    int page = 1,
  }) {
    return _apiDio.get<Map<String, dynamic>>(
      '/mars-photos/api/v1/rovers/$rover/photos',
      queryParameters: {
        if (earthDate != null)
          'earth_date': _formatDate(earthDate)
        else
          'sol': sol ?? 1000,
        'page': page,
      },
    );
  }

  Future<Response<Map<String, dynamic>>> getNearEarthObjects({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final effectiveStart = startDate ?? DateTime.now();
    final effectiveEnd = endDate ?? effectiveStart.add(const Duration(days: 7));

    return _apiDio.get<Map<String, dynamic>>(
      '/neo/rest/v1/feed',
      queryParameters: {
        'start_date': _formatDate(effectiveStart),
        'end_date': _formatDate(effectiveEnd),
      },
    );
  }

  Future<Response<Map<String, dynamic>>> searchMedia({
    required String query,
    int page = 1,
    String mediaType = 'image',
  }) {
    return _mediaDio.get<Map<String, dynamic>>(
      '/search',
      queryParameters: {'q': query, 'media_type': mediaType, 'page': page},
      options: Options(extra: const {'attachApiKey': false}),
    );
  }

  String _formatDate(DateTime date) => _dateFormat.format(date);
}
