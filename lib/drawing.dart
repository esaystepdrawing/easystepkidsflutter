import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------- Stroke

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  Stroke({required this.points, required this.color, required this.width});
}

// ---------------------------------------------------------------- Model

class DrawingModel extends ChangeNotifier {
  final List<Stroke> strokes = <Stroke>[];
  Stroke? _current;
  Color selectedColor = Colors.red;
  double lineWidth = 16;

  Stroke? get current => _current;
  bool get isEmpty => strokes.isEmpty && _current == null;

  void begin(Offset point) {
    _current = Stroke(
      points: <Offset>[point],
      color: selectedColor,
      width: lineWidth,
    );
    notifyListeners();
  }

  void extend(Offset point) {
    _current?.points.add(point);
    notifyListeners();
  }

  void end() {
    if (_current != null) strokes.add(_current!);
    _current = null;
    notifyListeners();
  }

  void undo() {
    if (strokes.isNotEmpty) strokes.removeLast();
    notifyListeners();
  }

  void clear() {
    strokes.clear();
    _current = null;
    notifyListeners();
  }

  void setColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  void setLineWidth(double width) {
    lineWidth = width;
    notifyListeners();
  }
}

// ---------------------------------------------------------------- Canvas

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({required this.model, super.key});

  final DrawingModel model;

  @override
  Widget build(BuildContext context) {
    // Listener (raw pointer events) rather than GestureDetector so a single
    // tap also paints a dot, matching DragGesture(minimumDistance: 0) on iOS.
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => model.begin(e.localPosition),
      onPointerMove: (e) => model.extend(e.localPosition),
      onPointerUp: (_) => model.end(),
      onPointerCancel: (_) => model.end(),
      child: CustomPaint(
        painter: _StrokePainter(model),
        size: Size.infinite,
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.model) : super(repaint: model);

  final DrawingModel model;

  @override
  void paint(Canvas canvas, Size size) {
    final all = <Stroke>[
      ...model.strokes,
      if (model.current != null) model.current!,
    ];

    for (final stroke in all) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (stroke.points.length == 1) {
        // A single tap draws a dot.
        canvas.drawPoints(
          PointMode.points,
          stroke.points,
          paint..strokeCap = StrokeCap.round,
        );
        continue;
      }

      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final p in stroke.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) => true;
}

// ---------------------------------------------------------------- Palette

class ColorPalette extends StatelessWidget {
  const ColorPalette({required this.model, super.key});

  final DrawingModel model;

  static const List<Color> colors = <Color>[
    Colors.red,
    Colors.orange,
    Color(0xFFF2BF00),
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors.map((color) {
              final selected = model.selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => model.setColor(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: selected ? 40 : 34,
                  height: selected ? 40 : 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: selected ? 4 : 0,
                    ),
                    boxShadow: selected
                        ? const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      )
                    ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Brush

class BrushPalette extends StatelessWidget {
  const BrushPalette({required this.model, super.key});

  final DrawingModel model;

  /// Thin / medium / thick. Thin matters for long words like "Wednesday"
  /// where a fat stroke smears adjacent letters together.
  static const List<double> sizes = <double>[6, 11, 18];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sizes.map((size) {
            final selected = (model.lineWidth - size).abs() < 0.5;
            return GestureDetector(
              onTap: () => model.setLineWidth(size),
              child: Container(
                width: 44,
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? Colors.black54 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: model.selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Background

class BackgroundPalette {
  static const List<Color> colors = <Color>[
    Color(0xFFFFF2CC), // cream
    Color(0xFFD9F2FF), // sky
    Color(0xFFE0FFE0), // mint
    Color(0xFFFFE0EB), // rose
    Color(0xFFEDE0FF), // lavender
    Color(0xFFFFEBD6), // peach
    Color(0xFFDBFAF5), // aqua
  ];

  static Color at(int index) => colors[index.abs() % colors.length];
}