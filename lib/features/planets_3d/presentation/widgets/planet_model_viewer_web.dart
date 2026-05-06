// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:model_viewer_plus/src/html_builder.dart';
import 'package:web/web.dart' as web;

class PlanetModelViewer extends StatefulWidget {
  const PlanetModelViewer({
    required this.src,
    this.backgroundColor = Colors.transparent,
    this.alt,
    this.autoRotate,
    this.autoRotateDelay,
    this.rotationPerSecond,
    this.cameraControls,
    this.disableZoom,
    this.disableTap,
    this.disablePan,
    this.touchAction,
    this.interactionPrompt,
    this.cameraOrbit,
    this.cameraTarget,
    this.minCameraOrbit,
    this.maxCameraOrbit,
    this.fieldOfView,
    this.minFieldOfView,
    this.maxFieldOfView,
    this.interpolationDecay,
    this.exposure,
    this.innerModelViewerHtml,
    this.relatedCss,
    this.relatedJs,
    this.javascriptChannels,
    this.debugLogging = false,
    super.key,
  });

  final String src;
  final Color backgroundColor;
  final String? alt;
  final bool? autoRotate;
  final int? autoRotateDelay;
  final String? rotationPerSecond;
  final bool? cameraControls;
  final bool? disableZoom;
  final bool? disableTap;
  final bool? disablePan;
  final TouchAction? touchAction;
  final InteractionPrompt? interactionPrompt;
  final String? cameraOrbit;
  final String? cameraTarget;
  final String? minCameraOrbit;
  final String? maxCameraOrbit;
  final String? fieldOfView;
  final String? minFieldOfView;
  final String? maxFieldOfView;
  final num? interpolationDecay;
  final double? exposure;
  final String? innerModelViewerHtml;
  final String? relatedCss;
  final String? relatedJs;
  final Set<JavascriptChannel>? javascriptChannels;
  final bool debugLogging;

  @override
  State<PlanetModelViewer> createState() => _PlanetModelViewerState();
}

class _PlanetModelViewerState extends State<PlanetModelViewer> {
  final String _viewType = 'galaxydox-planet-model-${UniqueKey()}';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_registerView());
  }

  Future<void> _registerView() async {
    final htmlTemplate = await rootBundle.loadString(
      'packages/model_viewer_plus/assets/template.html',
    );
    final html = _buildHtml(htmlTemplate);

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final root = web.HTMLHtmlElement()
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
        ..style.margin = '0'
        ..style.padding = '0'
        ..innerHTML = html.toJS;

      final relatedJs = widget.relatedJs;
      if (relatedJs != null && relatedJs.trim().isNotEmpty) {
        final script = web.document.createElement('script')
          ..textContent = relatedJs;
        root.appendChild(script);
      }

      return root;
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildHtml(String htmlTemplate) {
    if (widget.src.startsWith('file://')) {
      throw ArgumentError("file:// URL scheme can't be used in Flutter web.");
    }

    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate.replaceFirst(
        '<script type="module" src="model-viewer.min.js" defer></script>',
        '',
      ),
      src: widget.src,
      alt: widget.alt,
      cameraControls: widget.cameraControls,
      disablePan: widget.disablePan,
      disableTap: widget.disableTap,
      touchAction: widget.touchAction,
      disableZoom: widget.disableZoom,
      autoRotate: widget.autoRotate,
      autoRotateDelay: widget.autoRotateDelay,
      rotationPerSecond: widget.rotationPerSecond,
      interactionPrompt: widget.interactionPrompt,
      cameraOrbit: widget.cameraOrbit,
      cameraTarget: widget.cameraTarget,
      fieldOfView: widget.fieldOfView,
      maxCameraOrbit: widget.maxCameraOrbit,
      minCameraOrbit: widget.minCameraOrbit,
      maxFieldOfView: widget.maxFieldOfView,
      minFieldOfView: widget.minFieldOfView,
      interpolationDecay: widget.interpolationDecay,
      exposure: widget.exposure,
      backgroundColor: widget.backgroundColor,
      innerModelViewerHtml: widget.innerModelViewerHtml,
      relatedCss: widget.relatedCss,
      id: widget.key?.toString(),
      debugLogging: widget.debugLogging,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading Model Viewer...',
        ),
      );
    }

    return HtmlElementView(viewType: _viewType);
  }
}
