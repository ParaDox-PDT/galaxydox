import 'package:flutter_test/flutter_test.dart';
import 'package:galaxydox/core/navigation/galaxydox_deep_links.dart';

void main() {
  group('GalaxyDoxDeepLinks', () {
    test('builds wallpaper links on the public domain', () {
      final uri = GalaxyDoxDeepLinks.wallpaper('nebula-42');

      expect(uri.toString(), 'https://galaxydox.uz/wallpapers/nebula-42');
    });

    test('builds APOD links with a stable date query', () {
      final uri = GalaxyDoxDeepLinks.apod(date: DateTime(2026, 4, 22));

      expect(uri.toString(), 'https://galaxydox.uz/apod?date=2026-04-22');
    });

    test('parses only valid APOD dates', () {
      expect(
        GalaxyDoxDeepLinks.parseApodDate('2026-04-22'),
        DateTime(2026, 4, 22),
      );
      expect(GalaxyDoxDeepLinks.parseApodDate('22-04-2026'), isNull);
      expect(GalaxyDoxDeepLinks.parseApodDate(''), isNull);
    });
  });
}
