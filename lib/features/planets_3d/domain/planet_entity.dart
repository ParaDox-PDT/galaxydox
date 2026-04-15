import 'package:flutter/material.dart';

@immutable
class PlanetEntity {
  const PlanetEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.modelAssetPath,
    required this.thumbnailAssetPath,
    this.facts = const [],
    this.accentColor = const Color(0xFF9DD8FF),
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String modelAssetPath;
  final String thumbnailAssetPath;
  final List<String> facts;
  final Color accentColor;
}
