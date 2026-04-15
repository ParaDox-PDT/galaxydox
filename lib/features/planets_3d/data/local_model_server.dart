import 'dart:io';

import 'package:flutter/services.dart';

class LocalModelServer {
  LocalModelServer._();

  static LocalModelServer? _instance;
  static LocalModelServer get instance => _instance ??= LocalModelServer._();

  HttpServer? _server;
  final Map<String, Uint8List> _cache = {};

  Future<String> serveAsset(String assetPath) async {
    final fileName = assetPath.split('/').last;

    if (!_cache.containsKey(fileName)) {
      final data = await rootBundle.load(assetPath);
      _cache[fileName] = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
    }

    if (_server == null) {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen(_handleRequest);
    }

    return 'http://127.0.0.1:${_server!.port}/$fileName';
  }

  void _handleRequest(HttpRequest request) {
    final fileName = request.uri.pathSegments.lastOrNull;
    final bytes = fileName != null ? _cache[fileName] : null;

    if (bytes != null) {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.binary
        ..headers.set('Access-Control-Allow-Origin', '*')
        ..add(bytes)
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }

  Future<void> dispose() async {
    await _server?.close(force: true);
    _server = null;
    _cache.clear();
  }
}
