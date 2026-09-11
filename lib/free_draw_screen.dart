import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'drawing.dart';
import 'sound_help_sheet.dart';

class FreeDrawScreen extends StatefulWidget {
  const FreeDrawScreen({super.key});

  @override
  State<FreeDrawScreen> createState() => _FreeDrawScreenState();
}

class _FreeDrawScreenState extends State<FreeDrawScreen> {
  final DrawingModel _drawing = DrawingModel();

  @override
  void dispose() {
    _drawing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Draw'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.orange,
            tooltip: 'Clear',
            onPressed: _drawing.clear,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9EC), Color(0xFFEFF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _portraitLayout()
                  : _landscapeLayout();
            },
          ),
        ),
      ),
    );
  }

  // ── Portrait ────────────────────────────────────────────────────────

  Widget _portraitLayout() {
    return Column(
      children: [
        Expanded(child: _canvas()),
        const SizedBox(height: 8),
        BrushPalette(model: _drawing),
        const SizedBox(height: 4),
        ColorPalette(model: _drawing),
        const SizedBox(height: 4),
        _bottomBar(),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Landscape ───────────────────────────────────────────────────────

  Widget _landscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
            child: _canvas(),
          ),
        ),
        SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
            child: Column(
              children: [
                BrushPalette(model: _drawing),
                const SizedBox(height: 8),
                ColorPalette(model: _drawing),
                const Spacer(),
                _clearButton(),
                const SizedBox(height: 8),
                _soundHelpButton(),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Canvas ──────────────────────────────────────────────────────────

  Widget _canvas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              // Faint grid guide
              CustomPaint(
                painter: _GridPainter(),
                size: Size.infinite,
              ),
              // Drawing canvas
              Positioned.fill(
                child: DrawingCanvas(model: _drawing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom bar (portrait) ───────────────────────────────────────────

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _soundHelpButton(),
          _clearButton(),
        ],
      ),
    );
  }

  Widget _clearButton() {
    return GestureDetector(
      onTap: _drawing.clear,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 16, color: Colors.orange),
            SizedBox(width: 6),
            Text('Clear',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _soundHelpButton() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => SoundHelpSheet(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, size: 13, color: Colors.blue),
            SizedBox(width: 5),
            Text('Sound not working?',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

// ── Faint dot grid background ─────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}