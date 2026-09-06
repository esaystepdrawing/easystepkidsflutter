import 'dart:ui' show PointMode;
import 'models.dart';

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
  const ColorPalette({
    required this.model,
    this.isVertical = false,
    super.key,
  });

  final DrawingModel model;
  final bool isVertical;

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
        final children = colors.map((color) {
          final selected = model.selectedColor.value == color.value;
          final double diameter = isVertical ? (selected ? 32 : 26) : (selected ? 38 : 32);

          return GestureDetector(
            onTap: () => model.setColor(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.symmetric(
                horizontal: isVertical ? 0 : 4,
                vertical: isVertical ? 4 : 0,
              ),
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: selected ? 3 : 0,
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
        }).toList();

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: isVertical ? 2 : 4,
            horizontal: isVertical ? 4 : 2,
          ),
          child: isVertical
              ? SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Brush

class BrushPalette extends StatelessWidget {
  const BrushPalette({
    required this.model,
    this.isVertical = false,
    super.key,
  });

  final DrawingModel model;
  final bool isVertical;

  static const List<double> sizes = <double>[6, 11, 18];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        final children = sizes.map((size) {
          final selected = (model.lineWidth - size).abs() < 0.5;
          return GestureDetector(
            onTap: () => model.setLineWidth(size),
            child: Container(
              width: isVertical ? 32 : 40,
              height: isVertical ? 32 : 32,
              margin: EdgeInsets.symmetric(
                horizontal: isVertical ? 0 : 4,
                vertical: isVertical ? 3 : 0,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? Colors.black54 : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: size * (isVertical ? 0.75 : 1.0),
                  height: size * (isVertical ? 0.75 : 1.0),
                  decoration: BoxDecoration(
                    color: model.selectedColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }).toList();

        return isVertical
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Tracing Screen Layout

/// Responsive layout container:
/// • Horizontal (Landscape): Tracing Canvas on LEFT, Image/Guide on RIGHT.
/// • Vertical (Portrait): Image/Guide on TOP, Tracing Canvas below, Palettes at BOTTOM.
class TracingResponsiveLayout extends StatelessWidget {
  const TracingResponsiveLayout({
    required this.model,
    required this.canvasStack,
    required this.referenceImageOrGuide,
    this.topActions,
    super.key,
  });

  final DrawingModel model;
  final Widget canvasStack;             // Canvas with dotted letter/guide underneath
  final Widget referenceImageOrGuide;   // Visual asset image or reference card
  final Widget? topActions;             // Undo, Clear, Sound buttons

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left rail: Slim vertical color & brush pickers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              border: const Border(right: BorderSide(color: Colors.black12, width: 1)),
            ),
            child: Column(
              children: [
                BrushPalette(model: model, isVertical: true),
                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 1, color: Colors.black12),
                const SizedBox(height: 6),
                Expanded(child: ColorPalette(model: model, isVertical: true)),
              ],
            ),
          ),

          // Left area: Main Tracing Canvas
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  child: canvasStack,
                ),
              ),
            ),
          ),

          // Right area: Reference Image / Drawing / Example
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (topActions != null) ...[
                    topActions!,
                    const SizedBox(height: 8),
                  ],
                  Expanded(child: Center(child: referenceImageOrGuide)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Portrait / Vertical: standard stacked layout
    return Column(
      children: [
        if (topActions != null) topActions!,
        // Top: Reference Image
        SizedBox(
          height: 140,
          child: Center(child: referenceImageOrGuide),
        ),
        // Middle: Tracing Canvas
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: canvasStack,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Bottom: Palettes
        BrushPalette(model: model, isVertical: false),
        ColorPalette(model: model, isVertical: false),
        const SizedBox(height: 8),
      ],
    );
  }
}