class LocalModelServer {
  LocalModelServer._();

  static LocalModelServer? _instance;
  static LocalModelServer get instance => _instance ??= LocalModelServer._();

  Future<String> serveAsset(String assetPath) {
    throw UnsupportedError('3D models are not supported on this platform.');
  }

  Future<void> dispose() async {}
}
