import 'package:hive/hive.dart';

enum BookmarkContentType {
  apod,
  marsRover,
  nasaMedia,
  nearEarthObject;

  String get label {
    return switch (this) {
      BookmarkContentType.apod => 'APOD',
      BookmarkContentType.marsRover => 'Mars Rover',
      BookmarkContentType.nasaMedia => 'NASA Media',
      BookmarkContentType.nearEarthObject => 'NEO Watch',
    };
  }
}

class BookmarkItem {
  const BookmarkItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.contentType,
    required this.payloadJson,
    required this.savedAt,
    this.subtitle,
    this.metadataPrimary,
    this.metadataSecondary,
    this.date,
  });

  final String id;

  final String title;

  final String description;

  final String imageUrl;

  final BookmarkContentType contentType;

  final String payloadJson;

  final DateTime savedAt;

  final String? subtitle;

  final String? metadataPrimary;

  final String? metadataSecondary;

  final DateTime? date;

  bool get hasDescription => description.trim().isNotEmpty;

  BookmarkItem copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    BookmarkContentType? contentType,
    String? payloadJson,
    DateTime? savedAt,
    String? subtitle,
    String? metadataPrimary,
    String? metadataSecondary,
    DateTime? date,
  }) {
    return BookmarkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      contentType: contentType ?? this.contentType,
      payloadJson: payloadJson ?? this.payloadJson,
      savedAt: savedAt ?? this.savedAt,
      subtitle: subtitle ?? this.subtitle,
      metadataPrimary: metadataPrimary ?? this.metadataPrimary,
      metadataSecondary: metadataSecondary ?? this.metadataSecondary,
      date: date ?? this.date,
    );
  }
}

class BookmarkContentTypeAdapter extends TypeAdapter<BookmarkContentType> {
  @override
  final int typeId = 0;

  @override
  BookmarkContentType read(BinaryReader reader) {
    return BookmarkContentType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, BookmarkContentType obj) {
    writer.writeByte(obj.index);
  }
}

class BookmarkItemAdapter extends TypeAdapter<BookmarkItem> {
  @override
  final int typeId = 1;

  @override
  BookmarkItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (var index = 0; index < fieldCount; index++) {
      fields[reader.readByte()] = reader.read();
    }

    return BookmarkItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      contentType: fields[4] as BookmarkContentType,
      payloadJson: fields[5] as String,
      savedAt: fields[6] as DateTime,
      subtitle: fields[7] as String?,
      metadataPrimary: fields[8] as String?,
      metadataSecondary: fields[9] as String?,
      date: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.contentType)
      ..writeByte(5)
      ..write(obj.payloadJson)
      ..writeByte(6)
      ..write(obj.savedAt)
      ..writeByte(7)
      ..write(obj.subtitle)
      ..writeByte(8)
      ..write(obj.metadataPrimary)
      ..writeByte(9)
      ..write(obj.metadataSecondary)
      ..writeByte(10)
      ..write(obj.date);
  }
}
