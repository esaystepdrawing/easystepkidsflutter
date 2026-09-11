import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a traffic sign in Flutter Canvas matching the iOS SwiftUI version.
class TrafficSignWidget extends StatelessWidget {
  const TrafficSignWidget({
    required this.signKey,
    this.label = '',
    this.size = 160,
    super.key,
  });

  final String signKey;
  final String label;
  final double size;

  /// Normalizes incoming keys: handles prefixes (e.g. 'traffic_stop'), casing, and whitespace
  String get _normalizedKey {
    return signKey.trim().toLowerCase().replaceFirst('traffic_', '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _SignPainter(_normalizedKey),
        ),
        if (label.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────

class _SignPainter extends CustomPainter {
  final String signKey;
  const _SignPainter(this.signKey);

  // Colors matching iOS exactly
  static const _red    = Color(0xFFD91111);
  static const _yellow = Color(0xFFFFD966);
  static const _blue   = Color(0xFF1A6DB5);
  static const _green  = Color(0xFF22A740);

  Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _text(Canvas canvas, Size size, String text, Color color,
      double fontSize, {double dy = 0, double dx = 0}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        size.width / 2 - tp.width / 2 + dx,
        size.height / 2 - tp.height / 2 + dy,
      ),
    );
  }

  // ── Octagon (Stop sign) ───────────────────────────────────────────

  Path _octagon(double w, double h) {
    final cut = w * 0.29;
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();
  }

  // ── Triangle ─────────────────────────────────────────────────────

  Path _triangle(double w, double h) => Path()
    ..moveTo(w / 2, 0)
    ..lineTo(w, h)
    ..lineTo(0, h)
    ..close();

  // ── Pentagon ─────────────────────────────────────────────────────

  Path _pentagon(double w, double h) => Path()
    ..moveTo(w * 0.5, 0)
    ..lineTo(w, h * 0.38)
    ..lineTo(w * 0.82, h)
    ..lineTo(w * 0.18, h)
    ..lineTo(0, h * 0.38)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    switch (signKey) {
      case 'stop':       _stop(canvas, size);       break;
      case 'yield':      _yield(canvas, size);      break;
      case 'go':         _go(canvas, size);         break;
      case 'warning':    _warning(canvas, size);    break;
      case 'school':     _school(canvas, size);     break;
      case 'noentry':    _noEntry(canvas, size);    break;
      case 'parking':    _parking(canvas, size);    break;
      case 'pedestrian': _pedestrian(canvas, size); break;
      case 'speedlimit': _speedLimit(canvas, size); break;
      case 'railroad':   _railroad(canvas, size);   break;
      case 'oneway':     _oneWay(canvas, size);     break;
      case 'noparking':  _noParking(canvas, size);  break;
      case 'roundabout': _roundabout(canvas, size); break;
      case 'bikepath':   _bikePath(canvas, size);   break;
      case 'hospital':   _hospital(canvas, size);   break;
      default:           _warning(canvas, size);    break;
    }
  }

  @override
  bool shouldRepaint(_SignPainter old) => old.signKey != signKey;

  // ── 1. STOP — red octagon ─────────────────────────────────────────

  void _stop(Canvas canvas, Size s) {
    final oct = _octagon(s.width, s.height);
    canvas.drawPath(oct, _fill(_red));

    // Inner octagon border
    final iw = s.width * 0.84, ih = s.height * 0.84;
    canvas.save();
    canvas.translate(s.width * 0.08, s.height * 0.08);
    canvas.drawPath(_octagon(iw, ih), _stroke(Colors.white, s.width * 0.03));
    canvas.restore();

    _text(canvas, s, 'STOP', Colors.white, s.width * 0.22);
  }

  // ── 2. YIELD — red/white triangle ────────────────────────────────

  void _yield(Canvas canvas, Size s) {
    final h = s.height * 0.87;
    final tri = _triangle(s.width, h);
    canvas.drawPath(tri, _fill(Colors.white));
    canvas.drawPath(tri, _stroke(_red, s.width * 0.08));
    _text(canvas, s, 'YIELD', _red, s.width * 0.14, dy: s.height * 0.1);
  }

  // ── 3. GO — green circle with arrow ──────────────────────────────

  void _go(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _fill(_green),
    );
    _text(canvas, s, '→', Colors.white, s.width * 0.50);
  }

  // ── 4. WARNING — yellow triangle with ! ──────────────────────────

  void _warning(Canvas canvas, Size s) {
    final h = s.height * 0.87;
    final tri = _triangle(s.width, h);
    canvas.drawPath(tri, _fill(_yellow));
    canvas.drawPath(tri, _stroke(Colors.black45, s.width * 0.025));
    _text(canvas, s, '!', Colors.black87, s.width * 0.42,
        dy: s.height * 0.06);
  }

  // ── 5. SCHOOL — yellow pentagon ───────────────────────────────────

  void _school(Canvas canvas, Size s) {
    final pent = _pentagon(s.width, s.height * 0.95);
    canvas.drawPath(pent, _fill(_yellow));
    canvas.drawPath(pent, _stroke(Colors.black45, s.width * 0.025));
    _text(canvas, s, '🏫', Colors.black87, s.width * 0.32,
        dy: -s.height * 0.05);
    _text(canvas, s, 'SCHOOL', Colors.black87, s.width * 0.11,
        dy: s.height * 0.22);
  }

  // ── 6. NO ENTRY — red circle with white bar ───────────────────────

  void _noEntry(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _fill(_red),
    );
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width * 0.44,
      _stroke(Colors.white, s.width * 0.04),
    );
    // White horizontal bar
    final bar = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(s.width / 2, s.height / 2),
        width: s.width * 0.60,
        height: s.height * 0.16,
      ),
      Radius.circular(s.width * 0.04),
    );
    canvas.drawRRect(bar, _fill(Colors.white));
  }

  // ── 7. PARKING — blue square with P ──────────────────────────────

  void _parking(Canvas canvas, Size s) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s.width, s.height),
      Radius.circular(s.width * 0.10),
    );
    canvas.drawRRect(rr, _fill(_blue));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.07, s.height * 0.07,
            s.width * 0.86, s.height * 0.86),
        Radius.circular(s.width * 0.07),
      ),
      _stroke(Colors.white, s.width * 0.04),
    );
    _text(canvas, s, 'P', Colors.white, s.width * 0.52);
  }

  // ── 8. PEDESTRIAN — green rectangle with walking figure ───────────

  void _pedestrian(Canvas canvas, Size s) {
    final w = s.width * 0.80;
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH((s.width - w) / 2, 0, w, s.height),
      Radius.circular(s.width * 0.08),
    );
    canvas.drawRRect(rr, _fill(_green));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((s.width - w * 0.86) / 2, s.height * 0.06,
            w * 0.86, s.height * 0.88),
        Radius.circular(s.width * 0.06),
      ),
      _stroke(Colors.white, s.width * 0.04),
    );
    _text(canvas, s, '🚶', Colors.white, s.width * 0.36, dy: -s.height * 0.06);
    _text(canvas, s, 'WALK', Colors.white, s.width * 0.12, dy: s.height * 0.24);
  }

  // ── 9. SPEED LIMIT — white rectangle US-style ─────────────────────

  void _speedLimit(Canvas canvas, Size s) {
    final w = s.width * 0.78;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((s.width - w) / 2, 0, w, s.height),
        Radius.circular(s.width * 0.08),
      ),
      _fill(Colors.white),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (s.width - w) / 2 + s.width * 0.03,
          s.height * 0.03,
          w - s.width * 0.06,
          s.height * 0.94,
        ),
        Radius.circular(s.width * 0.06),
      ),
      _stroke(Colors.black, s.width * 0.03),
    );
    _text(canvas, s, 'SPEED', Colors.black, s.width * 0.10, dy: -s.height * 0.22);
    _text(canvas, s, 'LIMIT', Colors.black, s.width * 0.10, dy: -s.height * 0.08);
    _text(canvas, s, '50',    Colors.black, s.width * 0.34, dy: s.height * 0.12);
  }

  // ── 10. RAILROAD — yellow circle with RR/X ───────────────────────

  void _railroad(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _fill(_yellow),
    );
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width * 0.45,
      _stroke(Colors.black54, s.width * 0.025),
    );
    _text(canvas, s, 'RR', Colors.black87, s.width * 0.22, dy: -s.height * 0.1);
    _text(canvas, s, '✕',  Colors.black87, s.width * 0.34, dy: s.height * 0.1);
  }

  // ── 11. ONE WAY — black rectangle with arrow ──────────────────────

  void _oneWay(Canvas canvas, Size s) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, s.height * 0.25, s.width, s.height * 0.50),
      Radius.circular(s.width * 0.08),
    );
    canvas.drawRRect(rr, _fill(Colors.black));
    _text(canvas, s, '→ ONE WAY', Colors.white, s.width * 0.12);
  }

  // ── 12. NO PARKING — blue P with red slash ────────────────────────

  void _noParking(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _fill(Colors.white),
    );
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _stroke(_red, s.width * 0.07),
    );
    _text(canvas, s, 'P', _blue, s.width * 0.46);
    // Diagonal slash
    canvas.drawLine(
      Offset(s.width * 0.15, s.height * 0.85),
      Offset(s.width * 0.85, s.height * 0.15),
      _stroke(_red, s.width * 0.08),
    );
  }

  // ── 13. ROUNDABOUT — blue circle with circular arrow ─────────────

  void _roundabout(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _fill(_blue),
    );
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width * 0.44,
      _stroke(Colors.white, s.width * 0.04),
    );
    _text(canvas, s, '↻', Colors.white, s.width * 0.50);
  }

  // ── 14. BIKE PATH — green circle with bicycle ────────────────────

  void _bikePath(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width / 2,
      _fill(_green),
    );
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width * 0.44,
      _stroke(Colors.white, s.width * 0.04),
    );
    _text(canvas, s, '🚲', Colors.white, s.width * 0.40);
  }

  // ── 15. HOSPITAL — white square with red H ───────────────────────

  void _hospital(Canvas canvas, Size s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s.width, s.height),
        Radius.circular(s.width * 0.10),
      ),
      _fill(Colors.white),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.06, s.height * 0.06,
          s.width * 0.88, s.height * 0.88,
        ),
        Radius.circular(s.width * 0.07),
      ),
      _stroke(_red, s.width * 0.04),
    );
    _text(canvas, s, 'H', _red, s.width * 0.52);
  }
}