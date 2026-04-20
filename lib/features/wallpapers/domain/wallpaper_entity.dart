class WallpaperEntity {
  const WallpaperEntity({
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
}
