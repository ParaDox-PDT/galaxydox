import 'package:intl/intl.dart';

import '../../../../core/navigation/galaxydox_deep_links.dart';
import '../../../../core/utils/trusted_external_url.dart';
import '../../domain/entities/apod_item.dart';

String buildApodShareText(ApodItem item) {
  final shareUri = sanitizeTrustedExternalUri(
    item.isImage ? item.preferredImageUrl : item.url,
    allowedHosts: TrustedHostSets.nasaAndVideoHosts,
  );
  final explanation = item.explanation.trim();
  final shortExplanation = explanation.length > 180
      ? '${explanation.substring(0, 177)}...'
      : explanation;
  final deepLink = GalaxyDoxDeepLinks.apod(date: item.date);

  final buffer = StringBuffer()
    ..writeln(item.title)
    ..writeln(DateFormat.yMMMMd().format(item.date))
    ..writeln()
    ..writeln(shortExplanation)
    ..writeln()
    ..writeln('Open in GalaxyDox:')
    ..writeln(deepLink.toString());

  if (shareUri != null) {
    buffer
      ..writeln()
      ..writeln('Original NASA media:')
      ..write(shareUri.toString());
  }

  return buffer.toString().trim();
}
