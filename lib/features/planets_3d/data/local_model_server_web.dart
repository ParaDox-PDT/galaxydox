class LocalModelServer {
  LocalModelServer._();

  static LocalModelServer? _instance;
  static LocalModelServer get instance => _instance ??= LocalModelServer._();

  Future<String> serveFile(String filePath) async {
    return filePath;
  }

  Future<void> dispose() async {}
}
