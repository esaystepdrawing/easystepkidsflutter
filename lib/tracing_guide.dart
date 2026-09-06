import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ── Dash util ─────────────────────────────────────────────────────────

Path dashPath(Path source, {double dash = 16, double gap = 14}) {
  final dest = Path();
  for (final metric in source.computeMetrics()) {
    double distance = 0;
    bool draw = true;
    while (distance < metric.length) {
      final len = draw ? dash : gap;
      final end = math.min(distance + len, metric.length);
      if (draw) dest.addPath(metric.extractPath(distance, end), Offset.zero);
      distance = end;
      draw = !draw;
    }
  }
  return dest;
}

// ── Text guide ────────────────────────────────────────────────────────

// ── Text guide ────────────────────────────────────────────────────────

bool isArabicScript(String s) =>
    s.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

class DottedText extends StatelessWidget {
  const DottedText({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedTextPainter(text),
      size: Size.infinite,
    );
  }
}

class _DottedTextPainter extends CustomPainter {
  _DottedTextPainter(this.text);
  final String text;
  static const double _base = 200;

  TextPainter _painter(double fontSize, Paint paint) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          foreground: paint,
        ),
      ),
      textDirection:
      isArabicScript(text) ? TextDirection.rtl : TextDirection.ltr,
      textAlign: TextAlign.center,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty || size.isEmpty) return;

    final probe = _painter(_base, Paint()..color = Colors.black)
      ..layout(maxWidth: double.infinity);
    if (probe.width == 0 || probe.height == 0) return;

    final scale = math.min(
      size.width * 0.85 / probe.width,
      size.height * 0.85 / probe.height,
    );
    final fontSize = _base * scale;

    final fill = _painter(
      fontSize,
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black.withOpacity(0.06),
    )..layout(maxWidth: double.infinity);

    final outline = _painter(
      fontSize,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, fontSize * 0.022)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = Colors.grey.withOpacity(0.75),
    )..layout(maxWidth: double.infinity);

    final offset = Offset(
      (size.width - fill.width) / 2,
      (size.height - fill.height) / 2,
    );

    fill.paint(canvas, offset);
    outline.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_DottedTextPainter old) => old.text != text;
}

// ── Shape guide ───────────────────────────────────────────────────────

class DottedShape extends StatelessWidget {
  const DottedShape({required this.shapeKey, super.key});
  final String shapeKey;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedShapePainter(shapeKey),
      size: Size.infinite,
    );
  }
}

class _DottedShapePainter extends CustomPainter {
  _DottedShapePainter(this.shapeKey);
  final String shapeKey;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final side = math.min(size.width, size.height) * 0.8;
    final rect = Rect.fromLTWH(
      (size.width - side) / 2,
      (size.height - side) / 2,
      side,
      side,
    );
    final path = ShapeFactory.path(shapeKey, rect);

    // Faint fill
    canvas.drawPath(path,
        Paint()..color = Colors.black.withOpacity(0.05));

    // Outer dashed outline
    canvas.drawPath(
      dashPath(path, dash: 16, gap: 14),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = Colors.grey.withOpacity(0.8),
    );

    // Centerline — smaller inset path
    final innerScale = 0.55;
    final innerSide = side * innerScale;
    final innerRect = Rect.fromLTWH(
      (size.width - innerSide) / 2,
      (size.height - innerSide) / 2,
      innerSide,
      innerSide,
    );
    final innerPath = ShapeFactory.path(shapeKey, innerRect);
    canvas.drawPath(
      dashPath(innerPath, dash: 18, gap: 16),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.grey.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(_DottedShapePainter old) => old.shapeKey != shapeKey;
}

// ── Shape factory ─────────────────────────────────────────────────────

class ShapeFactory {
  ShapeFactory._();

  static Path path(String key, Rect rect) {
    switch (key) {
      case 'circle':    return Path()..addOval(rect);
      case 'square':    return Path()..addRect(rect);
      case 'rectangle':
        final h = rect.height * 0.6;
        return Path()..addRect(Rect.fromLTWH(
            rect.left, rect.center.dy - h / 2, rect.width, h));
      case 'oval':
        final h = rect.height * 0.6;
        return Path()..addOval(Rect.fromLTWH(
            rect.left, rect.center.dy - h / 2, rect.width, h));
      case 'triangle':  return _triangle(rect);
      case 'diamond':   return _diamond(rect);
      case 'star':      return _star(rect);
      case 'heart':     return _heart(rect);
      default:          return Path()..addOval(rect);
    }
  }

  static Path _triangle(Rect r) => Path()
    ..moveTo(r.center.dx, r.top)
    ..lineTo(r.right, r.bottom)
    ..lineTo(r.left, r.bottom)
    ..close();

  static Path _diamond(Rect r) => Path()
    ..moveTo(r.center.dx, r.top)
    ..lineTo(r.right, r.center.dy)
    ..lineTo(r.center.dx, r.bottom)
    ..lineTo(r.left, r.center.dy)
    ..close();

  static Path _star(Rect r) {
    final path = Path();
    final center = r.center;
    final outer = r.width / 2;
    final inner = outer * 0.4;
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? outer : inner;
      final p = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Path _heart(Rect r) {
    final w = r.width, h = r.height, x = r.left, y = r.top;
    return Path()
      ..moveTo(x + w / 2, y + h)
      ..cubicTo(x + w / 2, y + h * 0.75, x, y + h / 2, x, y + h / 4)
      ..arcTo(
          Rect.fromCircle(center: Offset(x + w / 4, y + h / 4), radius: w / 4),
          math.pi, math.pi, false)
      ..arcTo(
          Rect.fromCircle(center: Offset(x + 3 * w / 4, y + h / 4), radius: w / 4),
          math.pi, math.pi, false)
      ..cubicTo(x + w, y + h / 2, x + w / 2, y + h * 0.75, x + w / 2, y + h)
      ..close();
  }
}

// ── Glitter overlay ───────────────────────────────────────────────────

class GlitterParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double opacity;
  double rotation;

  GlitterParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    this.opacity = 1.0,
    this.rotation = 0,
  });
}

class GlitterController extends ChangeNotifier {
  final List<GlitterParticle> _particles = [];
  final math.Random _rnd = math.Random();

  static const _colors = [
    Colors.yellow, Colors.orange, Colors.pink,
    Colors.blue, Colors.green, Colors.purple,
    Colors.red, Colors.cyan,
  ];

  void addAt(Offset position) {
    for (int i = 0; i < 6; i++) {
      final angle = _rnd.nextDouble() * 2 * math.pi;
      final speed = 1.5 + _rnd.nextDouble() * 3;
      _particles.add(GlitterParticle(
        position: position,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        color: _colors[_rnd.nextInt(_colors.length)],
        size: 4 + _rnd.nextDouble() * 6,
        opacity: 1.0,
        rotation: _rnd.nextDouble() * math.pi,
      ));
    }
    _tick();
    notifyListeners();
  }

  void _tick() {
    _particles.removeWhere((p) => p.opacity <= 0);
    for (final p in _particles) {
      p.position += p.velocity;
      p.velocity = Offset(p.velocity.dx * 0.92, p.velocity.dy * 0.92 + 0.15);
      p.opacity -= 0.04;
      p.rotation += 0.15;
    }
    if (_particles.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 16), () {
        _tick();
        notifyListeners();
      });
    }
  }

  void clear() {
    _particles.clear();
    notifyListeners();
  }

  List<GlitterParticle> get particles => List.unmodifiable(_particles);
}

class GlitterOverlay extends StatelessWidget {
  const GlitterOverlay({required this.controller, super.key});
  final GlitterController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _GlitterPainter(controller.particles),
        size: Size.infinite,
      ),
    );
  }
}

class _GlitterPainter extends CustomPainter {
  const _GlitterPainter(this.particles);
  final List<GlitterParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0) continue;
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity.clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);

      // Draw a small star / diamond sparkle
      final path = Path()
        ..moveTo(0, -p.size / 2)
        ..lineTo(p.size / 6, -p.size / 6)
        ..lineTo(p.size / 2, 0)
        ..lineTo(p.size / 6, p.size / 6)
        ..lineTo(0, p.size / 2)
        ..lineTo(-p.size / 6, p.size / 6)
        ..lineTo(-p.size / 2, 0)
        ..lineTo(-p.size / 6, -p.size / 6)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GlitterPainter old) => true;
}