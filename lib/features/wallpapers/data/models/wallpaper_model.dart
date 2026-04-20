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

  factory WallpaperModel.fromMap(Map<dynamic, dynamic> map) {
    return WallpaperModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'created_at': createdAt?.millisecondsSinceEpoch,
  };

  WallpaperEntity toEntity() => WallpaperEntity(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    createdAt: createdAt,
  );
}
