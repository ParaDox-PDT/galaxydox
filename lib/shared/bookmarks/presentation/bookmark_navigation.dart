import 'package:flutter/material.dart';

import '../../../features/apod/presentation/pages/apod_detail_page.dart';
import '../../../features/mars_rover/presentation/pages/mars_rover_photo_detail_page.dart';
import '../../../features/nasa_search/presentation/pages/nasa_media_detail_page.dart';
import '../../../features/neo/presentation/pages/neo_detail_page.dart';
import '../bookmark_mapper.dart';
import '../data/models/bookmark_item.dart';

Future<void> openBookmarkDetail(
  BuildContext context,
  BookmarkItem bookmark,
) async {
  switch (bookmark.contentType) {
    case BookmarkContentType.apod:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ApodDetailPage(item: BookmarkMapper.toApod(bookmark)),
        ),
      );
    case BookmarkContentType.marsRover:
      final photo = BookmarkMapper.toMarsRoverPhoto(bookmark);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => MarsRoverPhotoDetailPage(
            photo: photo,
            heroTag: 'bookmark-mars-rover-${photo.id}',
          ),
        ),
      );
    case BookmarkContentType.nasaMedia:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => NasaMediaDetailPage(
            item: BookmarkMapper.toNasaMediaItem(bookmark),
          ),
        ),
      );
    case BookmarkContentType.nearEarthObject:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              NeoDetailPage(object: BookmarkMapper.toNearEarthObject(bookmark)),
        ),
      );
  }
}
