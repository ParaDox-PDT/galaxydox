import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

@immutable
class AuroraPaletteSet {
  const AuroraPaletteSet(this.colors);

  final List<Color> colors;
}

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.backgroundColor = AppColors.backgroundDeep,
    this.colors,
    this.paletteSets,
    this.animationDuration = const Duration(seconds: 42),
    this.blobCount = 7,
    this.blurStrength = 54,
    this.opacity = 0.9,
    this.enableVignette = true,
    this.enableNoiseOverlay = true,
    this.speedMultiplier = 1,
    this.noiseOpacity = 0.02,
  }) : assert(blobCount > 0),
       assert(blurStrength >= 0),
       assert(opacity >= 0 && opacity <= 1),
       assert(speedMultiplier > 0),
       assert(noiseOpacity >= 0 && noiseOpacity <= 1),
       assert(colors == null || colors.length >= 2),
       assert(paletteSets == null || paletteSets.length >= 2);

  static const List<Color> _defaultColors = [
    Color(0xFF08101E),
    Color(0xFF112243),
    Color(0xFF18356E),
    Color(0xFF2157A8),
    Color(0xFF2E8DDB),
    Color(0xFF45CFF5),
    Color(0xFF6656E8),
    Color(0xFFEFF6FF),
  ];

  static const List<AuroraPaletteSet> _defaultPaletteSets = [
    AuroraPaletteSet([
      Color(0xFF091120),
      Color(0xFF13274F),
      Color(0xFF1B468A),
      Color(0xFF1F74C6),
      Color(0xFF52D0FF),
      Color(0xFF6257EA),
      Color(0xFFF2F7FF),
    ]),
    AuroraPaletteSet([
      Color(0xFF081126),
      Color(0xFF152C61),
      Color(0xFF284D9C),
      Color(0xFF1D8CDD),
      Color(0xFF55E2FF),
      Color(0xFF7B5CF4),
      Color(0xFFE8F1FF),
    ]),
    AuroraPaletteSet([
      Color(0xFF0A1022),
      Color(0xFF1D2759),
      Color(0xFF3349AA),
      Color(0xFF386CD6),
      Color(0xFF36C7F4),
      Color(0xFF8551EA),
      Color(0xFFF5FAFF),
    ]),
    AuroraPaletteSet([
      Color(0xFF07111F),
      Color(0xFF10284D),
      Color(0xFF214988),
      Color(0xFF2478BF),
      Color(0xFF4ABBF0),
      Color(0xFF5A63E4),
      Color(0xFFEAF5FF),
    ]),
  ];

  final Widget? child;
  final Color backgroundColor;
  final List<Color>? colors;
  final List<AuroraPaletteSet>? paletteSets;
  final Duration animationDuration;
  final int blobCount;
  final double blurStrength;
  final double opacity;
  final bool enableVignette;
  final bool enableNoiseOverlay;
  final double speedMultiplier;
  final double noiseOpacity;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  )..repeat();

  late List<List<Color>> _resolvedPaletteSets = _resolvePaletteSets();

  @override
  void didUpdateWidget(covariant AuroraBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
      if (_controller.isAnimating) {
        _controller
          ..reset()
          ..repeat();
      }
    }

    if (oldWidget.colors != widget.colors ||
        oldWidget.paletteSets != widget.paletteSets) {
      _resolvedPaletteSets = _resolvePaletteSets();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.backgroundColor,
                  const Color(0xFF040B18),
                  const Color(0xFF071327),
                  widget.backgroundColor,
                ],
                stops: const [0, 0.24, 0.72, 1],
              ),
            ),
          ),
          IgnorePointer(
            child: RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _AuroraAtmospherePainter(
                      animation: _controller,
                      paletteSets: _resolvedPaletteSets,
                      speedMultiplier: widget.speedMultiplier,
                    ),
                    child: const SizedBox.expand(),
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.blurStrength * 0.56,
                      sigmaY: widget.blurStrength * 0.56,
                    ),
                    child: CustomPaint(
                      painter: _AuroraBlobLayerPainter(
                        animation: _controller,
                        paletteSets: _resolvedPaletteSets,
                        blobCount: math.max(3, widget.blobCount - 2),
                        layerStrength: 0.72,
                        layerDepth: 0.78,
                        layerIndex: 0,
                        speedMultiplier: widget.speedMultiplier,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.blurStrength,
                      sigmaY: widget.blurStrength,
                    ),
                    child: Opacity(
                      opacity: widget.opacity,
                      child: CustomPaint(
                        painter: _AuroraBlobLayerPainter(
                          animation: _controller,
                          paletteSets: _resolvedPaletteSets,
                          blobCount: widget.blobCount,
                          layerStrength: 1,
                          layerDepth: 1,
                          layerIndex: 1,
                          speedMultiplier: widget.speedMultiplier,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.enableNoiseOverlay)
            IgnorePointer(
              child: CustomPaint(
                painter: _NoisePainter(opacity: widget.noiseOpacity),
                child: const SizedBox.expand(),
              ),
            ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  stops: const [0, 0.18, 0.72, 1],
                ),
              ),
            ),
          ),
          if (widget.enableVignette)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.04,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.52),
                    ],
                    stops: const [0.34, 0.72, 1],
                  ),
                ),
              ),
            ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  List<List<Color>> _resolvePaletteSets() {
    if (widget.paletteSets case final palettes?) {
      assert(
        palettes.every((palette) => palette.colors.length >= 2),
        'Each AuroraPaletteSet must contain at least two colors.',
      );
      return palettes.map((palette) => List<Color>.unmodifiable(palette.colors)).toList(
        growable: false,
      );
    }

    if (widget.colors == null && widget.paletteSets == null) {
      return AuroraBackground._defaultPaletteSets
          .map((palette) => List<Color>.unmodifiable(palette.colors))
          .toList(growable: false);
    }

    final baseColors = widget.colors ?? AuroraBackground._defaultColors;
    return _derivePaletteSets(baseColors);
  }

  List<List<Color>> _derivePaletteSets(List<Color> baseColors) {
    return List<List<Color>>.generate(4, (paletteIndex) {
      final rotation = paletteIndex % baseColors.length;
      final hueShift = [-8.0, 12.0, -18.0, 8.0][paletteIndex];
      final saturationShift = [0.0, 0.06, -0.04, 0.03][paletteIndex];
      final lightnessShift = [-0.03, 0.02, -0.01, 0.03][paletteIndex];

      return List<Color>.generate(baseColors.length, (colorIndex) {
        final source = baseColors[(colorIndex + rotation) % baseColors.length];
        return _toneColor(
          source,
          hueShift: hueShift,
          saturationShift: saturationShift,
          lightnessShift: lightnessShift,
        );
      }, growable: false);
    }, growable: false);
  }
}

class _AuroraAtmospherePainter extends CustomPainter {
  _AuroraAtmospherePainter({
    required this.animation,
    required this.paletteSets,
    required this.speedMultiplier,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<List<Color>> paletteSets;
  final double speedMultiplier;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = _loop(animation.value * speedMultiplier);
    final phase = progress * math.pi * 2;

    final leftColor = _sampleSceneColor(
      paletteSets,
      progress,
      colorIndex: 1,
      phaseOffset: 0.06,
      intensity: 0.32,
    );
    final rightColor = _sampleSceneColor(
      paletteSets,
      progress,
      colorIndex: 3,
      phaseOffset: 0.2,
      intensity: 0.28,
    );
    final lowerColor = _sampleSceneColor(
      paletteSets,
      progress,
      colorIndex: 5,
      phaseOffset: 0.34,
      intensity: 0.22,
    );

    final leftCenter = Offset(
      size.width * _clampUnit(0.2 + 0.08 * math.sin(phase * 0.9)),
      size.height * _clampUnit(0.16 + 0.09 * math.cos(phase * 0.8 + 0.6)),
    );
    final rightCenter = Offset(
      size.width * _clampUnit(0.82 + 0.07 * math.cos(phase * 0.72 + 0.8)),
      size.height * _clampUnit(0.26 + 0.1 * math.sin(phase * 0.64 + 1.2)),
    );
    final lowerCenter = Offset(
      size.width * _clampUnit(0.54 + 0.09 * math.sin(phase * 0.56 + 1.1)),
      size.height * _clampUnit(0.88 + 0.04 * math.cos(phase * 0.74 + 0.7)),
    );

    _drawGlow(
      canvas,
      size,
      center: leftCenter,
      radius: size.shortestSide * 0.96,
      color: leftColor,
    );
    _drawGlow(
      canvas,
      size,
      center: rightCenter,
      radius: size.shortestSide * 0.84,
      color: rightColor,
    );
    _drawGlow(
      canvas,
      size,
      center: lowerCenter,
      radius: size.shortestSide * 0.92,
      color: lowerColor,
    );

    final bandColorA = _sampleSceneColor(
      paletteSets,
      progress,
      colorIndex: 2,
      phaseOffset: 0.12,
      intensity: 0.16,
    );
    final bandColorB = _sampleSceneColor(
      paletteSets,
      progress,
      colorIndex: 4,
      phaseOffset: 0.28,
      intensity: 0.14,
    );

    final bandRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bandPaint = Paint()
      ..blendMode = BlendMode.plus
      ..shader = LinearGradient(
        begin: Alignment(
          -1 + 0.22 * math.sin(phase * 0.5 + 0.4),
          -0.4 + 0.08 * math.cos(phase * 0.4),
        ),
        end: Alignment(
          1 - 0.18 * math.cos(phase * 0.52 + 1.1),
          0.5 + 0.08 * math.sin(phase * 0.44 + 0.8),
        ),
        colors: [
          Colors.transparent,
          bandColorA,
          bandColorB,
          Colors.transparent,
        ],
        stops: const [0, 0.22, 0.72, 1],
      ).createShader(bandRect);

    canvas.drawRect(bandRect, bandPaint);
  }

  void _drawGlow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: color.a * 0.45),
          Colors.transparent,
        ],
        stops: const [0, 0.38, 1],
      ).createShader(rect);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraAtmospherePainter oldDelegate) {
    return oldDelegate.paletteSets != paletteSets ||
        oldDelegate.speedMultiplier != speedMultiplier;
  }
}

class _AuroraBlobLayerPainter extends CustomPainter {
  _AuroraBlobLayerPainter({
    required this.animation,
    required this.paletteSets,
    required this.blobCount,
    required this.layerStrength,
    required this.layerDepth,
    required this.layerIndex,
    required this.speedMultiplier,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<List<Color>> paletteSets;
  final int blobCount;
  final double layerStrength;
  final double layerDepth;
  final int layerIndex;
  final double speedMultiplier;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = _loop(animation.value * speedMultiplier);
    final phase = progress * math.pi * 2;
    final minSide = size.shortestSide;

    for (var index = 0; index < blobCount; index++) {
      final seed = index + 1 + (layerIndex * 0.37);
      final blobPhase = phase + (seed * 0.82);
      final pulse = 0.5 + 0.5 * math.sin(blobPhase * 0.92 + seed * 1.7);
      final breathe = 0.5 + 0.5 * math.cos(blobPhase * 0.74 + seed * 1.16);

      final center = Offset(
        size.width *
            _clampUnit(
              0.5 +
                  0.24 * math.sin(blobPhase * (0.52 + (seed * 0.008))) +
                  0.12 * math.cos(blobPhase * (1.08 + (seed * 0.005)) + 0.8),
            ),
        size.height *
            _clampUnit(
              0.5 +
                  0.2 * math.cos(blobPhase * (0.48 + (seed * 0.01)) + 0.6) +
                  0.14 * math.sin(blobPhase * (0.94 + (seed * 0.006)) + 1.2),
            ),
      );

      final baseRadius =
          minSide *
          (0.2 +
              ((index % 4) * 0.035) +
              (0.03 * layerDepth) +
              (0.04 * pulse));
      final width = baseRadius * (1.24 + (0.32 * breathe));
      final height = baseRadius * (0.84 + (0.28 * pulse));
      final rotation =
          (math.pi / 10) * math.sin(blobPhase * 0.5 + (seed * 0.9));

      final primaryColor = _sampleBlobColor(
        paletteSets,
        progress,
        blobIndex: index,
        layerIndex: layerIndex,
        phaseOffset: seed * 0.043,
      );
      final secondaryColor = _sampleBlobColor(
        paletteSets,
        progress,
        blobIndex: index + 2,
        layerIndex: layerIndex + 1,
        phaseOffset: 0.18 + (seed * 0.031),
      );
      final blend = 0.22 + (0.16 * math.sin(blobPhase * 0.62 + seed));
      final blobColor = Color.lerp(primaryColor, secondaryColor, blend)!;

      final outerAlpha = (0.12 + (0.11 * pulse)) * layerStrength;
      final innerAlpha = (0.18 + (0.12 * breathe)) * layerStrength;
      final coreAlpha = (0.08 + (0.06 * pulse)) * layerStrength;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);

      final outerRect = Rect.fromCenter(
        center: Offset.zero,
        width: width * 2.9,
        height: height * 2.8,
      );
      final innerRect = Rect.fromCenter(
        center: Offset.zero,
        width: width * 1.6,
        height: height * 1.48,
      );

      final outerPaint = Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            blobColor.withValues(alpha: outerAlpha),
            blobColor.withValues(alpha: outerAlpha * 0.58),
            Colors.transparent,
          ],
          stops: const [0, 0.52, 1],
        ).createShader(outerRect);

      final innerPaint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: coreAlpha),
            blobColor.withValues(alpha: innerAlpha),
            Colors.transparent,
          ],
          stops: const [0, 0.2, 1],
        ).createShader(innerRect);

      canvas.drawOval(outerRect, outerPaint);
      canvas.drawOval(innerRect, innerPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraBlobLayerPainter oldDelegate) {
    return oldDelegate.paletteSets != paletteSets ||
        oldDelegate.blobCount != blobCount ||
        oldDelegate.layerStrength != layerStrength ||
        oldDelegate.layerDepth != layerDepth ||
        oldDelegate.layerIndex != layerIndex ||
        oldDelegate.speedMultiplier != speedMultiplier;
  }
}

class _NoisePainter extends CustomPainter {
  const _NoisePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(24);
    final paint = Paint();
    final density = ((size.width * size.height) / 4200).round();

    for (var index = 0; index < density; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final alpha = opacity * (0.18 + (random.nextDouble() * 0.82));
      final width = 0.6 + (random.nextDouble() * 1.1);
      final height = 0.6 + (random.nextDouble() * 1.1);

      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawRect(Rect.fromLTWH(dx, dy, width, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

double _loop(double value) => value - value.floorToDouble();

double _clampUnit(double value) => value.clamp(0.06, 0.94).toDouble();

double _smoothStep(double value) {
  final t = value.clamp(0, 1).toDouble();
  return t * t * (3 - (2 * t));
}

Color _sampleSceneColor(
  List<List<Color>> paletteSets,
  double progress, {
  required int colorIndex,
  required double phaseOffset,
  required double intensity,
}) {
  final color = _samplePaletteColor(
    paletteSets,
    progress,
    colorIndex: colorIndex,
    phaseOffset: phaseOffset,
  );
  return color.withValues(alpha: intensity);
}

Color _sampleBlobColor(
  List<List<Color>> paletteSets,
  double progress, {
  required int blobIndex,
  required int layerIndex,
  required double phaseOffset,
}) {
  final primary = _samplePaletteColor(
    paletteSets,
    progress,
    colorIndex: blobIndex + layerIndex,
    phaseOffset: phaseOffset,
  );
  final secondary = _samplePaletteColor(
    paletteSets,
    progress,
    colorIndex: blobIndex + 2 + layerIndex,
    phaseOffset: phaseOffset + 0.14,
  );
  return Color.lerp(primary, secondary, 0.24)!;
}

Color _samplePaletteColor(
  List<List<Color>> paletteSets,
  double progress, {
  required int colorIndex,
  required double phaseOffset,
}) {
  final paletteCount = paletteSets.length;
  final shifted = _loop(progress + phaseOffset) * paletteCount;
  final startPalette = shifted.floor() % paletteCount;
  final endPalette = (startPalette + 1) % paletteCount;
  final blend = _smoothStep(shifted - shifted.floorToDouble());
  final startColors = paletteSets[startPalette];
  final endColors = paletteSets[endPalette];
  final startColor = startColors[colorIndex % startColors.length];
  final endColor = endColors[(colorIndex + 1) % endColors.length];

  return Color.lerp(startColor, endColor, blend)!;
}

Color _toneColor(
  Color color, {
  required double hueShift,
  required double saturationShift,
  required double lightnessShift,
}) {
  final hsl = HSLColor.fromColor(color);
  if (hsl.saturation < 0.08) {
    return hsl
        .withLightness((hsl.lightness + (lightnessShift * 0.6)).clamp(0, 1))
        .toColor();
  }

  return hsl
      .withHue((hsl.hue + hueShift + 360) % 360)
      .withSaturation((hsl.saturation + saturationShift).clamp(0, 1))
      .withLightness((hsl.lightness + lightnessShift).clamp(0, 1))
      .toColor();
}
