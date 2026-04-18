import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/apod_model.dart';

final apodLocalDataSourceProvider = Provider<ApodLocalDataSource>((ref) {
  return const ApodLocalDataSourceImpl();
});

abstract interface class ApodLocalDataSource {
  Future<ApodModel?> getApod({DateTime? requestedDate});

  Future<void> cacheApod(ApodModel model, {DateTime? requestedDate});
}

class ApodLocalDataSourceImpl implements ApodLocalDataSource {
  const ApodLocalDataSourceImpl();

  static const boxName = 'apod_cache';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApodModel?> getApod({DateTime? requestedDate}) async {
    final key = _requestedKey(requestedDate);

    try {
      final raw = (await _box).get(key);
      if (raw == null) {
        return null;
      }

      final decoded = jsonDecode(raw);
      return ApodModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    } catch (error) {
      await _delete(key);
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Cached APOD entry could not be read.',
        cause: error,
      );
    }
  }

  @override
  Future<void> cacheApod(ApodModel model, {DateTime? requestedDate}) async {
    final payload = jsonEncode(model.toJson());
    final actualKey = _dateKey(model.date);
    final requestedKey = _requestedKey(requestedDate);

    try {
      final box = await _box;
      await box.put(actualKey, payload);

      if (requestedKey != actualKey) {
        await box.put(requestedKey, payload);
      }
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'APOD entry could not be cached on this device.',
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
        message: 'APOD cache could not be opened.',
        cause: error,
      );
    }
  }

  static String _requestedKey(DateTime? requestedDate) {
    if (requestedDate == null) {
      final today = _normalizeDate(DateTime.now());
      return 'latest_${_dateFormat.format(today)}';
    }

    return _dateKey(requestedDate);
  }

  static String _dateKey(DateTime date) {
    return 'date_${_dateFormat.format(_normalizeDate(date))}';
  }

  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
