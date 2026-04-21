import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/app_notification_entity.dart';

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.typeRaw,
    required this.routeId,
    required this.isRead,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String typeRaw;
  final String routeId;
  final bool isRead;
  final String? imageUrl;
  final DateTime? createdAt;

  factory AppNotificationModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppNotificationModel(
      id: doc.id,
      title: _readString(data['title']),
      body: _readString(data['body']),
      typeRaw: _readString(data['type']),
      routeId: _readString(data['route_id']),
      imageUrl: _readNullableString(data['image_url']),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      isRead: false,
    );
  }

  factory AppNotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return AppNotificationModel(
      id: _readString(map['id']),
      title: _readString(map['title']),
      body: _readString(map['body']),
      typeRaw: _readString(map['type']),
      routeId: _readString(map['route_id']),
      imageUrl: _readNullableString(map['image_url']),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      isRead: map['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'type': typeRaw,
    'route_id': routeId,
    'image_url': imageUrl,
    'created_at': createdAt?.millisecondsSinceEpoch,
    'is_read': isRead,
  };

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? typeRaw,
    String? routeId,
    bool? isRead,
    String? imageUrl,
    DateTime? createdAt,
    bool clearImage = false,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      typeRaw: typeRaw ?? this.typeRaw,
      routeId: routeId ?? this.routeId,
      isRead: isRead ?? this.isRead,
      imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AppNotificationEntity toEntity() => AppNotificationEntity(
    id: id,
    title: title,
    body: body,
    typeRaw: typeRaw,
    routeId: routeId,
    imageUrl: imageUrl,
    createdAt: createdAt,
    isRead: isRead,
  );

  static String _readString(Object? value) => value?.toString().trim() ?? '';

  static String? _readNullableString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
