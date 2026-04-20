import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/planet_entity.dart';

class PlanetModel extends PlanetEntity {
  const PlanetModel({
    required super.id,
    required super.index,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.modelUrl,
    required super.thumbnailUrl,
    required super.facts,
    required super.accentColor,
    required super.forAllDevice,
  });

  factory PlanetModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return PlanetModel(
      id: document.id,
      index: (data['index'] as num?)?.toInt() ?? 0,
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String).trim()
          : _formatFallbackTitle(document.id),
      subtitle: (data['subtitle'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      modelUrl: (data['model_url'] as String?)?.trim() ?? '',
      thumbnailUrl: (data['thumbnail_url'] as String?)?.trim() ?? '',
      facts: ((data['facts'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<String>()
          .map((fact) => fact.trim())
          .where((fact) => fact.isNotEmpty)
          .toList(growable: false),
      accentColor: _parseAccentColor(data['accent_color']),
      forAllDevice: data['for_all_device'] as bool? ?? true,
    );
  }

  static Color _parseAccentColor(Object? rawValue) {
    if (rawValue is int) {
      return Color(rawValue);
    }

    if (rawValue is String) {
      var normalized = rawValue.trim();
      if (normalized.startsWith('0x')) {
        normalized = normalized.substring(2);
      } else if (normalized.startsWith('#')) {
        normalized = normalized.substring(1);
      }

      if (normalized.length == 6) {
        normalized = 'FF$normalized';
      }

      final parsed = int.tryParse(normalized, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }

    return const Color(0xFF9DD8FF);
  }

  static String _formatFallbackTitle(String id) {
    return id
        .split('_')
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              '${segment.substring(0, 1).toUpperCase()}${segment.substring(1)}',
        )
        .join(' ');
  }
}
