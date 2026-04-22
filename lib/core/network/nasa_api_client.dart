import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../config/app_config.dart';
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
      NasaEndpoints.apod,
      queryParameters: {
        if (date != null) 'date': _formatDate(date),
        'hd': hd,
        'thumbs': true,
      },
    );
  }

  Future<Response<Map<String, dynamic>>> getMarsRoverPhotos({
    required String rover,
    int? sol,
    DateTime? earthDate,
    int page = 1,
  }) {
    return _apiDio.get<Map<String, dynamic>>(
      NasaEndpoints.marsRoverPhotos(rover),
      queryParameters: {
        if (earthDate != null)
          'earth_date': _formatDate(earthDate)
        else
          'sol': sol ?? 1000,
        'page': page,
      },
    );
  }

  Future<Response<List<dynamic>>> getLatestEpicNaturalImages() {
    return _apiDio.get<List<dynamic>>(NasaEndpoints.epicNatural);
  }

  Future<Response<List<dynamic>>> getEpicNaturalAvailableDates() {
    return _apiDio.get<List<dynamic>>(NasaEndpoints.epicNaturalAvailable);
  }

  Future<Response<List<dynamic>>> getEpicNaturalImagesByDate({
    required DateTime date,
  }) {
    return _apiDio.get<List<dynamic>>(
      NasaEndpoints.epicNaturalByDate(_formatDate(date)),
    );
  }

  Future<Response<Map<String, dynamic>>> getNearEarthObjects({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final (effectiveStart, effectiveEnd) = _resolveDateWindow(
      startDate: startDate,
      endDate: endDate,
    );

    return _apiDio.get<Map<String, dynamic>>(
      NasaEndpoints.nearEarthFeed,
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
      NasaEndpoints.mediaSearch,
      queryParameters: {'q': query, 'media_type': mediaType, 'page': page},
      options: Options(extra: const {RequestExtras.attachApiKey: false}),
    );
  }

  Future<Response<List<dynamic>>> searchMediaManifest({
    required String assetManifestUrl,
  }) {
    final manifestUri = Uri.parse(assetManifestUrl);

    return _mediaDio.get<List<dynamic>>(
      manifestUri.scheme.toLowerCase() == 'http'
          ? manifestUri.replace(scheme: 'https').toString()
          : manifestUri.toString(),
      options: Options(extra: const {RequestExtras.attachApiKey: false}),
    );
  }

  (DateTime, DateTime) _resolveDateWindow({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final effectiveStart = _normalizeDate(startDate ?? DateTime.now());
    final requestedEnd = _normalizeDate(
      endDate ?? effectiveStart.add(const Duration(days: 6)),
    );
    final maxAllowedEnd = effectiveStart.add(const Duration(days: 6));
    final effectiveEnd = requestedEnd.isBefore(effectiveStart)
        ? effectiveStart
        : requestedEnd.isAfter(maxAllowedEnd)
        ? maxAllowedEnd
        : requestedEnd;

    return (effectiveStart, effectiveEnd);
  }

  static String _formatDate(DateTime date) => _dateFormat.format(date);

  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
