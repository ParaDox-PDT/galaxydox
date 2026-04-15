import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/epic_image_model.dart';

final epicEarthLocalDataSourceProvider = Provider<EpicEarthLocalDataSource>((
  ref,
) {
  return const EpicEarthLocalDataSourceImpl();
});

abstract interface class EpicEarthLocalDataSource {
  Future<List<EpicImageModel>?> getLatestImages();

  Future<void> cacheLatestImages(List<EpicImageModel> images);

  Future<List<DateTime>?> getAvailableDates();

  Future<void> cacheAvailableDates(List<DateTime> dates);

  Future<List<EpicImageModel>?> getImagesByDate(DateTime date);

  Future<void> cacheImagesByDate(DateTime date, List<EpicImageModel> images);
}

class EpicEarthLocalDataSourceImpl implements EpicEarthLocalDataSource {
  const EpicEarthLocalDataSourceImpl();

  static const boxName = 'epic_earth_cache';
  static const _latestImagesKey = 'latest_images';
  static const _availableDatesKey = 'available_dates';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<List<EpicImageModel>?> getLatestImages() async {
    return _readImages(_latestImagesKey);
  }

  @override
  Future<void> cacheLatestImages(List<EpicImageModel> images) async {
    await _writeImages(_latestImagesKey, images);
  }

  @override
  Future<List<DateTime>?> getAvailableDates() async {
    try {
      final raw = (await _box).get(_availableDatesKey);
      if (raw == null) {
        return null;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((value) {
            final parsed = DateTime.parse(value as String);
            return DateTime(parsed.year, parsed.month, parsed.day);
          })
          .toList(growable: false)
        ..sort((a, b) => b.compareTo(a));
    } catch (error) {
      await _delete(_availableDatesKey);
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Cached EPIC available dates could not be read.',
        cause: error,
      );
    }
  }

  @override
  Future<void> cacheAvailableDates(List<DateTime> dates) async {
    try {
      final payload = dates
          .map((date) => DateTime(date.year, date.month, date.day))
          .map((date) => date.toIso8601String())
          .toList(growable: false);
      await (await _box).put(_availableDatesKey, jsonEncode(payload));
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'EPIC available dates could not be cached.',
        cause: error,
      );
    }
  }

  @override
  Future<List<EpicImageModel>?> getImagesByDate(DateTime date) async {
    return _readImages(_dateImagesKey(date));
  }

  @override
  Future<void> cacheImagesByDate(
    DateTime date,
    List<EpicImageModel> images,
  ) async {
    await _writeImages(_dateImagesKey(date), images);
  }

  Future<List<EpicImageModel>?> _readImages(String key) async {
    try {
      final raw = (await _box).get(key);
      if (raw == null) {
        return null;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) {
            return EpicImageModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          })
          .toList(growable: false);
    } catch (error) {
      await _delete(key);
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Cached EPIC images could not be read.',
        cause: error,
      );
    }
  }

  Future<void> _writeImages(String key, List<EpicImageModel> images) async {
    try {
      final payload = images.map((image) => image.toJson()).toList();
      await (await _box).put(key, jsonEncode(payload));
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'EPIC images could not be cached.',
        cause: error,
      );
    }
  }

  Future<void> _delete(String key) async {
    if (!Hive.isBoxOpen(boxName)) {
      return;
    }

    await Hive.box<String>(boxName).delete(key);
  }

  Future<Box<String>> get _box async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<String>(boxName);
      }

      return Hive.openBox<String>(boxName);
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'EPIC cache could not be opened.',
        cause: error,
      );
    }
  }

  static String _dateImagesKey(DateTime date) {
    return 'images_${_dateFormat.format(date)}';
  }
}
