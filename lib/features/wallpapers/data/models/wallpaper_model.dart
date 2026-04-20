import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/wallpaper_entity.dart';

class WallpaperModel {
  const WallpaperModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime? createdAt;

  factory WallpaperModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return WallpaperModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['image_url'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  WallpaperEntity toEntity() => WallpaperEntity(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    createdAt: createdAt,
  );
}
