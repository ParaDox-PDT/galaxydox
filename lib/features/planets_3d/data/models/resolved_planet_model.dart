class ResolvedPlanetModel {
  const ResolvedPlanetModel({
    required this.viewerSrc,
    required this.isStoredLocally,
    required this.wasLoadedFromCache,
    this.localFilePath,
  });

  final String viewerSrc;
  final bool isStoredLocally;
  final bool wasLoadedFromCache;
  final String? localFilePath;
}
