import 'dart:io';

class LocalModelServer {
  LocalModelServer._();

  static LocalModelServer? _instance;
  static LocalModelServer get instance => _instance ??= LocalModelServer._();

  HttpServer? _server;
  final Map<String, String> _servedFiles = {};
  final Map<String, String> _fileKeysByPath = {};
  int _nextKey = 0;

  Future<String> serveFile(String filePath) async {
    if (_server == null) {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen(_handleRequest);
    }

    final key = _fileKeysByPath[filePath] ?? 'model_${_nextKey++}';
    _fileKeysByPath[filePath] = key;
    _servedFiles[key] = filePath;
    return 'http://127.0.0.1:${_server!.port}/$key';
  }

  Future<void> _handleRequest(HttpRequest request) async {
    _applyCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    final key = request.uri.pathSegments.lastOrNull;
    final filePath = key != null ? _servedFiles[key] : null;
    final file = filePath != null ? File(filePath) : null;

    if (file != null && await file.exists()) {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = _resolveContentType(file.path);
      request.response.headers.set('Accept-Ranges', 'bytes');
      if (request.method == 'HEAD') {
        await request.response.close();
        return;
      }
      await request.response.addStream(file.openRead());
      await request.response.close();
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  Future<void> dispose() async {
    await _server?.close(force: true);
    _server = null;
    _servedFiles.clear();
    _fileKeysByPath.clear();
  }

  void _applyCorsHeaders(HttpResponse response) {
    response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
      ..set('Access-Control-Allow-Headers', '*');
  }

  ContentType _resolveContentType(String filePath) {
    final normalized = filePath.toLowerCase();
    if (normalized.endsWith('.glb')) {
      return ContentType('model', 'gltf-binary');
    }
    if (normalized.endsWith('.gltf')) {
      return ContentType('model', 'gltf+json');
    }
    return ContentType.binary;
  }
}
