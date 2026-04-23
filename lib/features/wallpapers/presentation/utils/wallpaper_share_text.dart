import '../../../../core/navigation/galaxydox_deep_links.dart';
import '../../domain/wallpaper_entity.dart';

String buildWallpaperShareText(WallpaperEntity wallpaper) {
  final description = wallpaper.description.trim();
  final shortDescription = description.length > 180
      ? '${description.substring(0, 177)}...'
      : description;
  final deepLink = GalaxyDoxDeepLinks.wallpaper(wallpaper.id);

  final buffer = StringBuffer()..writeln(wallpaper.title);

  if (shortDescription.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(shortDescription);
  }

  buffer
    ..writeln()
    ..writeln('Open in GalaxyDox:')
    ..write(deepLink.toString());

  return buffer.toString().trim();
}
