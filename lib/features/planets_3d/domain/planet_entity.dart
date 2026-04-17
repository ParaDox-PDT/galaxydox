import 'package:flutter/material.dart';

@immutable
class PlanetEntity {
  const PlanetEntity({
    required this.id,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.modelUrl,
    this.thumbnailUrl = '',
    this.facts = const [],
    this.accentColor = const Color(0xFF9DD8FF),
  });

  final String id;
  final int index;
  final String title;
  final String subtitle;
  final String description;
  final String modelUrl;
  final String thumbnailUrl;
  final List<String> facts;
  final Color accentColor;
}
