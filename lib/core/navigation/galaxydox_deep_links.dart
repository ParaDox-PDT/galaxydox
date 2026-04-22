import 'package:intl/intl.dart';

import '../../app/router/app_routes.dart';
import '../config/app_config.dart';

abstract final class GalaxyDoxDeepLinks {
  static const _defaultHost = 'galaxydox.uz';
  static final DateFormat _apodDateFormat = DateFormat('yyyy-MM-dd');

  static Uri get _baseUri {
    final override = AppConfig.marketingUri;
    if (override != null && override.host.isNotEmpty) {
      return override.replace(path: '', queryParameters: null, fragment: null);
    }

    return Uri.https(_defaultHost);
  }

  static Uri wallpaper(String wallpaperId) =>
      _build(pathSegments: ['wallpapers', wallpaperId]);

  static Uri apod({required DateTime date}) => _build(
    pathSegments: ['apod'],
    queryParameters: {AppRoutes.apodDateQueryKey: formatApodDate(date)},
  );

  static String formatApodDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _apodDateFormat.format(normalized);
  }

  static DateTime? parseApodDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
      return null;
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return null;
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static Uri _build({
    required List<String> pathSegments,
    Map<String, String>? queryParameters,
  }) {
    final base = _baseUri;
    final allSegments = [
      ...base.pathSegments.where((segment) => segment.isNotEmpty),
      ...pathSegments,
    ];

    final effectiveQueryParameters =
        queryParameters == null || queryParameters.isEmpty
        ? null
        : queryParameters;

    if (base.hasPort) {
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.port,
        pathSegments: allSegments,
        queryParameters: effectiveQueryParameters,
      );
    }

    return Uri(
      scheme: base.scheme,
      host: base.host,
      pathSegments: allSegments,
      queryParameters: effectiveQueryParameters,
    );
  }
}
