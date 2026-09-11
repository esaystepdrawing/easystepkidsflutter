import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a seasonal illustration for each month.
class MonthIllustration extends StatelessWidget {
  const MonthIllustration({
    required this.monthIndex, // 0=Jan, 1=Feb, ... 11=Dec
    required this.monthName,
    this.size = 200,
    super.key,
  });

  final int monthIndex;
  final String monthName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(size * 0.12),
            border: Border.all(color: _borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: _borderColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.10),
            child: CustomPaint(
              size: Size(size, size),
              painter: _MonthPainter(monthIndex),
            ),
          ),
        ),
      ],
    );
  }

  Color get _bgColor {
    switch (monthIndex) {
      case 0:  return const Color(0xFFE8F4FD); // Jan - light blue
      case 1:  return const Color(0xFFFFF0F3); // Feb - light pink
      case 2:  return const Color(0xFFE8F8E8); // Mar - light green
      case 3:  return const Color(0xFFE8F4FD); // Apr - light blue
      case 4:  return const Color(0xFFE8F8E8); // May - light green
      case 5:  return const Color(0xFFFFF8E1); // Jun - light yellow
      case 6:  return const Color(0xFFFFF3E0); // Jul - light orange
      case 7:  return const Color(0xFFE8F8E8); // Aug - light green
      case 8:  return const Color(0xFFE8F4FD); // Sep - light blue
      case 9:  return const Color(0xFFFFF3E0); // Oct - light orange
      case 10: return const Color(0xFFFFF8E1); // Nov - light yellow
      case 11: return const Color(0xFFE8F4FD); // Dec - light blue
      default: return const Color(0xFFF5F5F5);
    }
  }

  Color get _borderColor {
    const colors = [
      Color(0xFF90CAF9), Color(0xFFF48FB1), Color(0xFFA5D6A7),
      Color(0xFF90CAF9), Color(0xFFA5D6A7), Color(0xFFFFE082),
      Color(0xFFFFCC80), Color(0xFFA5D6A7), Color(0xFF90CAF9),
      Color(0xFFFFCC80), Color(0xFFFFE082), Color(0xFF90CAF9),
    ];
    return colors[monthIndex % 12];
  }
}

class _MonthPainter extends CustomPainter {
  final int month;
  const _MonthPainter(this.month);

  Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c..style = PaintingStyle.stroke
    ..strokeWidth = w..strokeCap = StrokeCap.round;

  void _text(Canvas canvas, Size size, String text, Color color,
      double fontSize, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(text: text,
          style: TextStyle(color: color, fontSize: fontSize,
              fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size s) {
    switch (month) {
      case 0:  _january(canvas, s);   break;
      case 1:  _february(canvas, s);  break;
      case 2:  _march(canvas, s);     break;
      case 3:  _april(canvas, s);     break;
      case 4:  _may(canvas, s);       break;
      case 5:  _june(canvas, s);      break;
      case 6:  _july(canvas, s);      break;
      case 7:  _august(canvas, s);    break;
      case 8:  _september(canvas, s); break;
      case 9:  _october(canvas, s);   break;
      case 10: _november(canvas, s);  break;
      case 11: _december(canvas, s);  break;
    }
  }

  @override
  bool shouldRepaint(_MonthPainter o) => o.month != month;

  // ── Jan: Snowman ──────────────────────────────────────────────────

  void _january(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Snow ground
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.75, s.width, s.height * 0.25),
        _fill(const Color(0xFFE3F2FD)));
    // Body
    canvas.drawCircle(Offset(cx, s.height * 0.72), s.width * 0.22,
        _fill(Colors.white));
    canvas.drawCircle(Offset(cx, s.height * 0.72), s.width * 0.22,
        _stroke(const Color(0xFF90CAF9), 2));
    // Head
    canvas.drawCircle(Offset(cx, s.height * 0.42), s.width * 0.15,
        _fill(Colors.white));
    canvas.drawCircle(Offset(cx, s.height * 0.42), s.width * 0.15,
        _stroke(const Color(0xFF90CAF9), 2));
    // Hat
    canvas.drawRect(
        Rect.fromLTWH(cx - s.width * 0.16, s.height * 0.18,
            s.width * 0.32, s.height * 0.14),
        _fill(const Color(0xFF1A237E)));
    canvas.drawRect(
        Rect.fromLTWH(cx - s.width * 0.20, s.height * 0.30,
            s.width * 0.40, s.height * 0.04),
        _fill(const Color(0xFF1A237E)));
    // Eyes
    canvas.drawCircle(Offset(cx - s.width * 0.05, s.height * 0.39),
        s.width * 0.025, _fill(Colors.black));
    canvas.drawCircle(Offset(cx + s.width * 0.05, s.height * 0.39),
        s.width * 0.025, _fill(Colors.black));
    // Nose
    final nosePath = Path()
      ..moveTo(cx, s.height * 0.42)
      ..lineTo(cx + s.width * 0.06, s.height * 0.44)
      ..lineTo(cx, s.height * 0.46)
      ..close();
    canvas.drawPath(nosePath, _fill(Colors.orange));
    // Buttons
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(cx, s.height * (0.60 + i * 0.07)),
          s.width * 0.025, _fill(Colors.black));
    }
    // Snow flakes
    _text(canvas, s, '❄', Colors.blue.shade200, s.width * 0.12,
        s.width * 0.15, s.height * 0.15);
    _text(canvas, s, '❄', Colors.blue.shade200, s.width * 0.10,
        s.width * 0.85, s.height * 0.20);
  }

  // ── Feb: Hearts ───────────────────────────────────────────────────

  void _february(Canvas canvas, Size s) {
    // Background gradient feel
    final positions = [
      [0.5, 0.35, 0.28], [0.25, 0.55, 0.18], [0.75, 0.60, 0.15],
      [0.5, 0.72, 0.12], [0.3, 0.25, 0.10], [0.72, 0.28, 0.10],
    ];
    final colors = [
      const Color(0xFFE91E63), const Color(0xFFF06292),
      const Color(0xFFFF80AB), const Color(0xFFE91E63),
      const Color(0xFFF48FB1), const Color(0xFFFF4081),
    ];
    for (int i = 0; i < positions.length; i++) {
      _drawHeart(canvas,
          Offset(s.width * positions[i][0], s.height * positions[i][1]),
          s.width * positions[i][2], colors[i]);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    final x = center.dx, y = center.dy;
    path.moveTo(x, y + r * 0.6);
    path.cubicTo(x, y, x - r * 1.2, y - r * 0.6, x - r * 0.6, y - r);
    path.arcTo(Rect.fromCircle(center: Offset(x - r * 0.3, y - r), radius: r * 0.6),
        math.pi, math.pi, false);
    path.arcTo(Rect.fromCircle(center: Offset(x + r * 0.3, y - r), radius: r * 0.6),
        math.pi, math.pi, false);
    path.cubicTo(x + r * 1.2, y - r * 0.6, x, y, x, y + r * 0.6);
    path.close();
    canvas.drawPath(path, _fill(color));
  }

  // ── Mar: Tree with flowers ────────────────────────────────────────

  void _march(Canvas canvas, Size s) {
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.7),
        _fill(const Color(0xFFB3E5FC)));
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.3),
        _fill(const Color(0xFF81C784)));
    // Trunk
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.44, s.height * 0.45,
            s.width * 0.12, s.height * 0.30),
        _fill(const Color(0xFF795548)));
    // Canopy
    canvas.drawCircle(Offset(s.width * 0.5, s.height * 0.32),
        s.width * 0.28, _fill(const Color(0xFF66BB6A)));
    canvas.drawCircle(Offset(s.width * 0.5, s.height * 0.32),
        s.width * 0.28, _fill(const Color(0xFF81C784)));
    // Flowers
    const flowerPositions = [
      [0.15, 0.78], [0.35, 0.82], [0.60, 0.78], [0.80, 0.82],
    ];
    for (final p in flowerPositions) {
      canvas.drawCircle(Offset(s.width * p[0], s.height * p[1]),
          s.width * 0.06, _fill(Colors.white));
      canvas.drawCircle(Offset(s.width * p[0], s.height * p[1]),
          s.width * 0.03, _fill(Colors.yellow));
    }
    // Cloud
    canvas.drawCircle(Offset(s.width * 0.2, s.height * 0.15),
        s.width * 0.10, _fill(Colors.white));
    canvas.drawCircle(Offset(s.width * 0.3, s.height * 0.12),
        s.width * 0.12, _fill(Colors.white));
    canvas.drawCircle(Offset(s.width * 0.4, s.height * 0.16),
        s.width * 0.09, _fill(Colors.white));
  }

  // ── Apr: Rain & Umbrella ──────────────────────────────────────────

  void _april(Canvas canvas, Size s) {
    // Sky - grey
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height),
        _fill(const Color(0xFFB0BEC5)));
    // Cloud
    for (final p in [[0.3, 0.2, 0.18], [0.5, 0.15, 0.20], [0.65, 0.22, 0.15]]) {
      canvas.drawCircle(Offset(s.width * p[0], s.height * p[1]),
          s.width * p[2], _fill(const Color(0xFF78909C)));
    }
    // Rain drops
    final rainPaint = _stroke(const Color(0xFF90CAF9), 2);
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 4; j++) {
        final x = s.width * (0.1 + i * 0.18);
        final y = s.height * (0.35 + j * 0.14);
        canvas.drawLine(Offset(x, y), Offset(x - 4, y + 10), rainPaint);
      }
    }
    // Umbrella handle
    final handlePath = Path()
      ..moveTo(s.width * 0.5, s.height * 0.62)
      ..lineTo(s.width * 0.5, s.height * 0.85)
      ..arcTo(
          Rect.fromCircle(center: Offset(s.width * 0.42, s.height * 0.85),
              radius: s.width * 0.08),
          0, math.pi, false);
    canvas.drawPath(handlePath, _stroke(const Color(0xFF795548), 4));
    // Umbrella top
    final umbrellaPath = Path()
      ..moveTo(s.width * 0.15, s.height * 0.62)
      ..quadraticBezierTo(s.width * 0.5, s.height * 0.30,
          s.width * 0.85, s.height * 0.62)
      ..close();
    canvas.drawPath(umbrellaPath,
        _fill(const Color(0xFFFF7043)));
    // Umbrella ribs
    for (int i = 0; i < 5; i++) {
      final x = s.width * (0.15 + i * 0.175);
      canvas.drawLine(Offset(s.width * 0.5, s.height * 0.62),
          Offset(x, s.height * 0.62),
          _stroke(Colors.white.withOpacity(0.5), 1));
    }
  }

  // ── May: Flowers & Butterflies ────────────────────────────────────

  void _may(Canvas canvas, Size s) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.65),
        _fill(const Color(0xFFE1F5FE)));
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.65, s.width, s.height * 0.35),
        _fill(const Color(0xFF81C784)));
    // Flowers
    final flowerData = [
      [0.2, 0.6, 0xFFE91E63], [0.5, 0.55, 0xFFAB47BC],
      [0.78, 0.60, 0xFFFF7043],
    ];
    for (final f in flowerData) {
      final x = s.width * f[0];
      final y = s.height * f[1];
      final color = Color(f[2] as int);
      // Stem
      canvas.drawLine(Offset(x, y), Offset(x, s.height * 0.85),
          _stroke(const Color(0xFF388E3C), 3));
      // Petals
      for (int i = 0; i < 6; i++) {
        final angle = i * math.pi / 3;
        canvas.drawCircle(
            Offset(x + math.cos(angle) * s.width * 0.06,
                y + math.sin(angle) * s.width * 0.06),
            s.width * 0.05, _fill(color));
      }
      canvas.drawCircle(Offset(x, y), s.width * 0.04, _fill(Colors.yellow));
    }
    // Butterfly
    _drawButterfly(canvas, Offset(s.width * 0.75, s.height * 0.25),
        s.width * 0.12, const Color(0xFF7E57C2));
    _drawButterfly(canvas, Offset(s.width * 0.3, s.height * 0.2),
        s.width * 0.10, const Color(0xFF26C6DA));
  }

  void _drawButterfly(Canvas canvas, Offset center, double r, Color color) {
    for (int side in [-1, 1]) {
      for (int wing in [-1, 1]) {
        final path = Path();
        path.addOval(Rect.fromCenter(
            center: Offset(center.dx + side * r * 0.8,
                center.dy + wing * r * 0.5),
            width: r * 1.2, height: r * 0.8));
        canvas.drawPath(path, _fill(color.withOpacity(0.8)));
      }
    }
    canvas.drawCircle(center, r * 0.12, _fill(Colors.black));
  }

  // ── Jun: Beach & Sun ─────────────────────────────────────────────

  void _june(Canvas canvas, Size s) {
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.55),
        _fill(const Color(0xFF81D4FA)));
    // Sea
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.55, s.width, s.height * 0.20),
        _fill(const Color(0xFF0288D1)));
    // Sand
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28),
        _fill(const Color(0xFFFFCC80)));
    // Sun
    final sunC = Offset(s.width * 0.78, s.height * 0.22);
    canvas.drawCircle(sunC, s.width * 0.14, _fill(const Color(0xFFFFD600)));
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
          Offset(sunC.dx + math.cos(angle) * s.width * 0.16,
              sunC.dy + math.sin(angle) * s.width * 0.16),
          Offset(sunC.dx + math.cos(angle) * s.width * 0.22,
              sunC.dy + math.sin(angle) * s.width * 0.22),
          _stroke(const Color(0xFFFFD600), 3));
    }
    // Sunglasses
    canvas.drawCircle(Offset(sunC.dx - s.width * 0.05, sunC.dy),
        s.width * 0.04, _fill(const Color(0xFF1565C0)));
    canvas.drawCircle(Offset(sunC.dx + s.width * 0.05, sunC.dy),
        s.width * 0.04, _fill(const Color(0xFF1565C0)));
    canvas.drawLine(
        Offset(sunC.dx - s.width * 0.01, sunC.dy),
        Offset(sunC.dx + s.width * 0.01, sunC.dy),
        _stroke(Colors.black, 1.5));
    // Palm tree
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.62, s.height * 0.42, s.width * 0.06, s.height * 0.35),
        _fill(const Color(0xFF795548)));
    for (int i = 0; i < 4; i++) {
      final angle = -math.pi / 4 + i * math.pi / 6;
      final path = Path()
        ..moveTo(s.width * 0.65, s.height * 0.42)
        ..quadraticBezierTo(
            s.width * 0.65 + math.cos(angle) * s.width * 0.15,
            s.height * 0.42 + math.sin(angle) * s.height * 0.1,
            s.width * 0.65 + math.cos(angle) * s.width * 0.28,
            s.height * 0.42 + math.sin(angle) * s.height * 0.18);
      canvas.drawPath(path, _stroke(const Color(0xFF388E3C), 4));
    }
  }

  // ── Jul: Beach ball & Palm ────────────────────────────────────────

  void _july(Canvas canvas, Size s) {
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.5),
        _fill(const Color(0xFF81D4FA)));
    // Sea
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.5, s.width, s.height * 0.2),
        _fill(const Color(0xFF0288D1)));
    // Sand
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.68, s.width, s.height * 0.32),
        _fill(const Color(0xFFFFCC80)));
    // Palm tree (left)
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.08, s.height * 0.30, s.width * 0.06, s.height * 0.42),
        _fill(const Color(0xFF795548)));
    for (int i = 0; i < 4; i++) {
      final angle = -math.pi / 3 + i * math.pi / 5;
      final path = Path()
        ..moveTo(s.width * 0.11, s.height * 0.30)
        ..quadraticBezierTo(
            s.width * 0.11 + math.cos(angle) * s.width * 0.12,
            s.height * 0.30 + math.sin(angle) * s.height * 0.08,
            s.width * 0.11 + math.cos(angle) * s.width * 0.24,
            s.height * 0.30 + math.sin(angle) * s.height * 0.15);
      canvas.drawPath(path, _stroke(const Color(0xFF388E3C), 4));
    }
    // Beach ball
    final ballC = Offset(s.width * 0.65, s.height * 0.75);
    final ballR = s.width * 0.16;
    canvas.drawCircle(ballC, ballR, _fill(Colors.white));
    final ballColors = [Colors.red, Colors.blue, Colors.yellow, Colors.green];
    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(ballC.dx, ballC.dy)
        ..arcTo(Rect.fromCircle(center: ballC, radius: ballR),
            i * math.pi / 2, math.pi / 2, false)
        ..close();
      canvas.drawPath(path, _fill(ballColors[i].withOpacity(0.85)));
    }
    canvas.drawCircle(ballC, ballR, _stroke(Colors.white, 2));
    // Star fish
    _text(canvas, s, '⭐', Colors.orange, s.width * 0.1,
        s.width * 0.35, s.height * 0.82);
  }

  // ── Aug: Watermelon ───────────────────────────────────────────────

  void _august(Canvas canvas, Size s) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height),
        _fill(const Color(0xFFF1F8E9)));
    // Picnic cloth
    final clothPath = Path()
      ..addRect(Rect.fromLTWH(s.width * 0.05, s.height * 0.55,
          s.width * 0.9, s.height * 0.35));
    canvas.drawPath(clothPath, _fill(const Color(0xFFEF9A9A)));
    // Cloth pattern
    final patternPaint = _stroke(Colors.white, 2);
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
          Offset(s.width * (0.05 + i * 0.18), s.height * 0.55),
          Offset(s.width * (0.05 + i * 0.18), s.height * 0.90),
          patternPaint);
    }
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
          Offset(s.width * 0.05, s.height * (0.55 + i * 0.09)),
          Offset(s.width * 0.95, s.height * (0.55 + i * 0.09)),
          patternPaint);
    }
    // Whole watermelon (half)
    final wmC = Offset(s.width * 0.35, s.height * 0.52);
    canvas.drawCircle(wmC, s.width * 0.22, _fill(const Color(0xFF388E3C)));
    // Lighter stripe
    canvas.drawArc(Rect.fromCircle(center: wmC, radius: s.width * 0.20),
        -math.pi, math.pi, false, _fill(const Color(0xFF66BB6A)));
    // Slice
    final slicePath = Path()
      ..moveTo(s.width * 0.62, s.height * 0.48)
      ..lineTo(s.width * 0.90, s.height * 0.65)
      ..lineTo(s.width * 0.62, s.height * 0.65)
      ..close();
    canvas.drawPath(slicePath, _fill(const Color(0xFFEF5350)));
    canvas.drawPath(slicePath, _stroke(const Color(0xFF388E3C), 3));
    // Seeds on slice
    for (final p in [[0.72, 0.58], [0.78, 0.62], [0.68, 0.62]]) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(s.width * p[0], s.height * p[1]),
              width: 6, height: 10),
          _fill(const Color(0xFF212121)));
    }
  }

  // ── Sep: School bus ───────────────────────────────────────────────

  void _september(Canvas canvas, Size s) {
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.65),
        _fill(const Color(0xFFB3E5FC)));
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.65, s.width, s.height * 0.35),
        _fill(const Color(0xFF9E9E9E)));
    // Road line
    canvas.drawLine(Offset(0, s.height * 0.75),
        Offset(s.width, s.height * 0.75),
        _stroke(Colors.white, 3));
    // School
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.55, s.height * 0.25,
            s.width * 0.40, s.height * 0.42),
        _fill(const Color(0xFFEF5350)));
    // Roof
    final roofPath = Path()
      ..moveTo(s.width * 0.50, s.height * 0.25)
      ..lineTo(s.width * 0.75, s.height * 0.10)
      ..lineTo(s.width * 1.0, s.height * 0.25)
      ..close();
    canvas.drawPath(roofPath, _fill(const Color(0xFFB71C1C)));
    // Door
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.68, s.height * 0.50,
            s.width * 0.12, s.height * 0.18),
        _fill(const Color(0xFF4E342E)));
    // Windows school
    for (final p in [[0.58, 0.35], [0.82, 0.35]]) {
      canvas.drawRect(
          Rect.fromLTWH(s.width * p[0], s.height * p[1],
              s.width * 0.10, s.height * 0.10),
          _fill(const Color(0xFF81D4FA)));
    }
    // Bus
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * 0.02, s.height * 0.57,
                s.width * 0.50, s.height * 0.18),
            Radius.circular(s.width * 0.04)),
        _fill(const Color(0xFFFDD835)));
    // Bus windows
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
          Rect.fromLTWH(s.width * (0.06 + i * 0.14), s.height * 0.60,
              s.width * 0.10, s.height * 0.07),
          _fill(const Color(0xFF81D4FA)));
    }
    // Wheels
    for (final x in [0.10, 0.38]) {
      canvas.drawCircle(Offset(s.width * x, s.height * 0.76),
          s.width * 0.06, _fill(Colors.black));
      canvas.drawCircle(Offset(s.width * x, s.height * 0.76),
          s.width * 0.03, _fill(Colors.grey));
    }
    // Clock
    canvas.drawCircle(Offset(s.width * 0.75, s.height * 0.22),
        s.width * 0.07, _fill(Colors.white));
    canvas.drawCircle(Offset(s.width * 0.75, s.height * 0.22),
        s.width * 0.07, _stroke(Colors.black, 1));
    canvas.drawLine(Offset(s.width * 0.75, s.height * 0.22),
        Offset(s.width * 0.75, s.height * 0.17),
        _stroke(Colors.black, 2));
    canvas.drawLine(Offset(s.width * 0.75, s.height * 0.22),
        Offset(s.width * 0.79, s.height * 0.22),
        _stroke(Colors.black, 2));
  }

  // ── Oct: Pumpkin & Autumn ─────────────────────────────────────────

  void _october(Canvas canvas, Size s) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.65),
        _fill(const Color(0xFFFFF8E1)));
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.65, s.width, s.height * 0.35),
        _fill(const Color(0xFFD7CCC8)));
    // Autumn tree
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.60, s.height * 0.30, s.width * 0.08, s.height * 0.38),
        _fill(const Color(0xFF5D4037)));
    canvas.drawCircle(Offset(s.width * 0.65, s.height * 0.22),
        s.width * 0.22, _fill(const Color(0xFFFF8F00)));
    canvas.drawCircle(Offset(s.width * 0.65, s.height * 0.22),
        s.width * 0.18, _fill(const Color(0xFFFFA000)));
    // Falling leaves
    for (final p in [[0.25, 0.45], [0.40, 0.35], [0.80, 0.50]]) {
      _text(canvas, s, '🍂', Colors.orange, s.width * 0.08,
          s.width * p[0], s.height * p[1]);
    }
    // Pumpkin
    final pC = Offset(s.width * 0.30, s.height * 0.70);
    final pr = s.width * 0.20;
    // Pumpkin segments
    for (final dx in [-0.12, 0.0, 0.12]) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(pC.dx + s.width * dx, pC.dy),
              width: pr * 0.8, height: pr * 1.1),
          _fill(const Color(0xFFFF6F00)));
    }
    // Face
    canvas.drawCircle(Offset(pC.dx - s.width * 0.06, pC.dy - s.height * 0.03),
        s.width * 0.03, _fill(Colors.black));
    canvas.drawCircle(Offset(pC.dx + s.width * 0.06, pC.dy - s.height * 0.03),
        s.width * 0.03, _fill(Colors.black));
    final mouthPath = Path()
      ..moveTo(pC.dx - s.width * 0.08, pC.dy + s.height * 0.04)
      ..quadraticBezierTo(pC.dx, pC.dy + s.height * 0.08,
          pC.dx + s.width * 0.08, pC.dy + s.height * 0.04);
    canvas.drawPath(mouthPath, _stroke(Colors.black, 2));
    // Stem
    canvas.drawRect(
        Rect.fromLTWH(pC.dx - s.width * 0.025, pC.dy - pr * 0.55,
            s.width * 0.05, s.height * 0.07),
        _fill(const Color(0xFF388E3C)));
  }

  // ── Nov: Bare tree & leaves ───────────────────────────────────────

  void _november(Canvas canvas, Size s) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.7),
        _fill(const Color(0xFFECEFF1)));
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.3),
        _fill(const Color(0xFFBCAAA4)));
    // Bare tree trunk
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.44, s.height * 0.30, s.width * 0.10, s.height * 0.42),
        _fill(const Color(0xFF4E342E)));
    // Branches
    final branches = [
      [0.49, 0.30, 0.20, 0.15],
      [0.49, 0.30, 0.75, 0.15],
      [0.49, 0.40, 0.15, 0.30],
      [0.49, 0.40, 0.82, 0.30],
      [0.49, 0.50, 0.25, 0.42],
      [0.49, 0.50, 0.72, 0.42],
    ];
    for (final b in branches) {
      canvas.drawLine(
          Offset(s.width * b[0], s.height * b[1]),
          Offset(s.width * b[2], s.height * b[3]),
          _stroke(const Color(0xFF4E342E), 4));
    }
    // Falling leaves
    for (final p in [
      [0.15, 0.50], [0.30, 0.65], [0.65, 0.55],
      [0.80, 0.62], [0.20, 0.75], [0.70, 0.75],
    ]) {
      _text(canvas, s, '🍁', Colors.brown, s.width * 0.07,
          s.width * p[0], s.height * p[1]);
    }
  }

  // ── Dec: Christmas tree ───────────────────────────────────────────

  void _december(Canvas canvas, Size s) {
    // Night sky
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height),
        _fill(const Color(0xFF1A237E)));
    // Snow ground
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
        _fill(Colors.white));
    // Stars
    for (final p in [[0.1, 0.1], [0.3, 0.05], [0.7, 0.08], [0.9, 0.12],
      [0.15, 0.25], [0.85, 0.20]]) {
      _text(canvas, s, '✦', Colors.yellow, s.width * 0.06,
          s.width * p[0], s.height * p[1]);
    }
    // Tree layers
    final layers = [
      [0.50, 0.18, 0.16],
      [0.50, 0.32, 0.24],
      [0.50, 0.48, 0.32],
      [0.50, 0.64, 0.38],
    ];
    for (final l in layers) {
      final path = Path()
        ..moveTo(s.width * l[0], s.height * (l[1] - l[2] * 0.6))
        ..lineTo(s.width * (l[0] + l[2]), s.height * l[1])
        ..lineTo(s.width * (l[0] - l[2]), s.height * l[1])
        ..close();
      canvas.drawPath(path, _fill(const Color(0xFF2E7D32)));
      canvas.drawPath(path, _stroke(const Color(0xFF1B5E20), 1));
    }
    // Trunk
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.44, s.height * 0.64,
            s.width * 0.12, s.height * 0.15),
        _fill(const Color(0xFF5D4037)));
    // Ornaments
    final ornaments = [
      [0.35, 0.40, 0xFFE53935], [0.65, 0.38, 0xFFFFD600],
      [0.30, 0.55, 0xFFFFD600], [0.70, 0.52, 0xFF1565C0],
      [0.42, 0.62, 0xFFE53935], [0.58, 0.60, 0xFF00897B],
    ];
    for (final o in ornaments) {
      canvas.drawCircle(Offset(s.width * o[0], s.height * o[1]),
          s.width * 0.04, _fill(Color(o[2] as int)));
    }
    // Star on top
    _text(canvas, s, '⭐', Colors.yellow, s.width * 0.14,
        s.width * 0.50, s.height * 0.10);
    // Gifts
    for (final g in [[0.22, 0.84, 0xFFE53935], [0.78, 0.84, 0xFF1565C0]]) {
      canvas.drawRect(
          Rect.fromLTWH(s.width * (g[0] as double) - s.width * 0.08,
              s.height * (g[1] as double) - s.height * 0.06,
              s.width * 0.16, s.height * 0.12),
          _fill(Color(g[2] as int)));
      canvas.drawLine(
          Offset(s.width * (g[0] as double), s.height * (g[1] as double) - s.height * 0.06),
          Offset(s.width * (g[0] as double), s.height * (g[1] as double) + s.height * 0.06),
          _stroke(Colors.white, 2));
      canvas.drawLine(
          Offset(s.width * (g[0] as double) - s.width * 0.08, s.height * (g[1] as double)),
          Offset(s.width * (g[0] as double) + s.width * 0.08, s.height * (g[1] as double)),
          _stroke(Colors.white, 2));
    }
  }
}