class LocalModelServer {
  LocalModelServer._();

  static LocalModelServer? _instance;
  static LocalModelServer get instance => _instance ??= LocalModelServer._();

  Future<String> serveAsset(String assetPath) async {
    return Uri.base.resolve('assets/$assetPath').toString();
  }

  Future<void> dispose() async {}
}
