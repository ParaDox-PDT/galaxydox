import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> _log(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    if (kDebugMode) {
      final params = parameters != null && parameters.isNotEmpty
          ? ' ${parameters.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
          : '';
      debugPrint('[Analytics] $name$params');
    }
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // --- Planet 3D ---

  Future<void> logPlanetViewed({
    required String planetId,
    required String planetName,
  }) => _log('planet_viewed', {'planet_id': planetId, 'planet_name': planetName});

  // --- APOD ---

  Future<void> logApodDateChanged(DateTime date) => _log(
    'apod_date_changed',
    {'selected_date': date.toIso8601String().substring(0, 10)},
  );

  Future<void> logApodShared() => _log('apod_shared');

  Future<void> logApodHdOpened() => _log('apod_hd_opened');

  // --- NASA Search ---

  Future<void> logSearchPerformed(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value();
    if (kDebugMode) debugPrint('[Analytics] search term=$trimmed');
    return _analytics.logSearch(searchTerm: trimmed);
  }

  // --- Mars Rover ---

  Future<void> logMarsRoverPhotoViewed() => _log('mars_rover_photo_viewed');

  // --- EPIC Earth ---

  Future<void> logEpicImageViewed() => _log('epic_image_viewed');

  // --- NEO ---

  Future<void> logNeoDetailViewed() => _log('neo_detail_viewed');

  // --- Bookmarks ---

  Future<void> logBookmarkAdded(String contentType) =>
      _log('bookmark_added', {'content_type': contentType});
}
