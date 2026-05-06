import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class PlanetModelViewer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ModelViewer(
      backgroundColor: backgroundColor,
      src: src,
      alt: alt,
      autoRotate: autoRotate,
      autoRotateDelay: autoRotateDelay,
      rotationPerSecond: rotationPerSecond,
      cameraControls: cameraControls,
      disableZoom: disableZoom,
      disableTap: disableTap,
      disablePan: disablePan,
      touchAction: touchAction,
      interactionPrompt: interactionPrompt,
      cameraOrbit: cameraOrbit,
      cameraTarget: cameraTarget,
      minCameraOrbit: minCameraOrbit,
      maxCameraOrbit: maxCameraOrbit,
      fieldOfView: fieldOfView,
      minFieldOfView: minFieldOfView,
      maxFieldOfView: maxFieldOfView,
      interpolationDecay: interpolationDecay,
      exposure: exposure,
      innerModelViewerHtml: innerModelViewerHtml,
      relatedCss: relatedCss,
      relatedJs: relatedJs,
      javascriptChannels: javascriptChannels,
      debugLogging: debugLogging,
    );
  }
}
