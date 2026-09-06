import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'data/content_dataset.dart';
import 'models.dart';
import 'tracing_guide.dart';
import 'traffic_sign_widget.dart';

// ── Puzzle Category ───────────────────────────────────────────────────

enum PuzzleCategory {
  alphabets,
  numbers,
  colors,
  shapes,
  trafficSigns,
  wordTest;

  String get label {
    switch (this) {
      case PuzzleCategory.alphabets:    return 'ABC';
      case PuzzleCategory.numbers:      return '123';
      case PuzzleCategory.colors:       return 'Colors';
      case PuzzleCategory.shapes:       return 'Shapes';
      case PuzzleCategory.trafficSigns: return 'Traffic';
      case PuzzleCategory.wordTest:     return 'Words';
    }
  }

  String get title {
    switch (this) {
      case PuzzleCategory.alphabets:    return 'Alphabets';
      case PuzzleCategory.numbers:      return 'Numbers';
      case PuzzleCategory.colors:       return 'Colors';
      case PuzzleCategory.shapes:       return 'Shapes';
      case PuzzleCategory.trafficSigns: return 'Traffic Signs';
      case PuzzleCategory.wordTest:     return 'Words';
    }
  }

  String get icon {
    switch (this) {
      case PuzzleCategory.alphabets:    return '🔤';
      case PuzzleCategory.numbers:      return '🔢';
      case PuzzleCategory.colors:       return '🎨';
      case PuzzleCategory.shapes:       return '⭐';
      case PuzzleCategory.trafficSigns: return '🚦';
      case PuzzleCategory.wordTest:     return '📝';
    }
  }

  Color get color {
    switch (this) {
      case PuzzleCategory.alphabets:    return const Color(0xFF3B6CF4);
      case PuzzleCategory.numbers:      return const Color(0xFFFF6B1A);
      case PuzzleCategory.colors:       return const Color(0xFFE84545);
      case PuzzleCategory.shapes:       return const Color(0xFF2DA882);
      case PuzzleCategory.trafficSigns: return const Color(0xFFD91111);
      case PuzzleCategory.wordTest:     return const Color(0xFF7C5CDB);
    }
  }
}

// ── Feedback Controller & Full-Screen Firecracker System ──────────────

enum FeedbackType { correct, wrong }

class PuzzleFeedbackEffect {
  final FeedbackType type;
  final List<_EffectParticle> particles;

  PuzzleFeedbackEffect({
    required this.type,
    required this.particles,
  });
}

class _EffectParticle {
  double x, y, vx, vy, size;
  final Color color;
  final bool isStar;
  final double gravity;

  _EffectParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    this.isStar = false,
    this.gravity = 1.8,
  });

  void update() {
    x += vx * 0.08;
    y += vy * 0.08;
    vy += gravity; // Gravity pull for realistic fireworks drop
    vx *= 0.98;    // Air drag
  }
}

class PuzzleFeedbackController extends ChangeNotifier {
  PuzzleFeedbackEffect? currentEffect;
  final math.Random _rnd = math.Random();
  AnimationController? _ticker;

  void trigger({
    required bool isCorrect,
    required Offset position,
    required BuildContext context,
    String? correctSpoken,
  }) {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final tts = context.read<TTSProvider>();
    final screenSize = MediaQuery.of(context).size;
    final particles = <_EffectParticle>[];

    if (isCorrect) {
      tts.speak('🎉 Yay! Fantastic job!', lang.speechCode);

      const firecrackerColors = [
        Colors.amber, Colors.orangeAccent, Colors.redAccent,
        Colors.lightGreenAccent, Colors.cyanAccent, Colors.purpleAccent,
        Colors.pinkAccent, Colors.yellowAccent,
      ];

      // 5 explosion origin points across the full screen
      final centers = [
        Offset(screenSize.width * 0.2, screenSize.height * 0.35),
        Offset(screenSize.width * 0.8, screenSize.height * 0.35),
        Offset(screenSize.width * 0.5, screenSize.height * 0.25),
        Offset(screenSize.width * 0.35, screenSize.height * 0.6),
        Offset(screenSize.width * 0.65, screenSize.height * 0.6),
        position, // Tap origin
      ];

      // Spawn 30-35 particles per burst origin point
      for (final origin in centers) {
        for (int i = 0; i < 32; i++) {
          final angle = _rnd.nextDouble() * 2 * math.pi;
          final speed = 80 + _rnd.nextDouble() * 260;
          particles.add(_EffectParticle(
            x: origin.dx,
            y: origin.dy,
            vx: math.cos(angle) * speed,
            vy: math.sin(angle) * speed - 40,
            color: firecrackerColors[_rnd.nextInt(firecrackerColors.length)],
            size: 8 + _rnd.nextDouble() * 10,
            isStar: _rnd.nextBool(),
            gravity: 2.2,
          ));
        }
      }
    } else {
      final cheer = correctSpoken != null ? 'Almost! Try again' : 'Try again!';
      tts.speak(cheer, lang.speechCode);

      // Encouraging sparkles focused around the card
      const sparkColors = [Colors.amberAccent, Colors.pinkAccent, Colors.lightBlueAccent];
      for (int i = 0; i < 28; i++) {
        final angle = _rnd.nextDouble() * 2 * math.pi;
        final speed = 30 + _rnd.nextDouble() * 80;
        particles.add(_EffectParticle(
          x: position.dx,
          y: position.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: sparkColors[_rnd.nextInt(sparkColors.length)],
          size: 6 + _rnd.nextDouble() * 6,
          isStar: true,
          gravity: 0.5,
        ));
      }
    }

    currentEffect = PuzzleFeedbackEffect(
      type: isCorrect ? FeedbackType.correct : FeedbackType.wrong,
      particles: particles,
    );
    notifyListeners();

    // Fade out / clear after explosion
    Future.delayed(Duration(milliseconds: isCorrect ? 2400 : 1400), () {
      currentEffect = null;
      notifyListeners();
    });
  }
}

class PuzzleFeedbackOverlayPainter extends CustomPainter {
  final PuzzleFeedbackEffect? effect;
  PuzzleFeedbackOverlayPainter(this.effect);

  @override
  void paint(Canvas canvas, Size size) {
    if (effect == null) return;

    for (final p in effect!.particles) {
      p.update();

      final paint = Paint()..color = p.color.withOpacity(0.95);
      final offset = Offset(p.x, p.y);

      if (p.isStar) {
        _drawSparkleStar(canvas, offset, p.size, paint);
      } else {
        canvas.drawCircle(offset, p.size / 2, paint);
      }
    }
  }

  void _drawSparkleStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final half = size / 2;
    path.moveTo(center.dx, center.dy - half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - half);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => effect != null;
}

// ── Main Wheel Spinner Screen ─────────────────────────────────────────

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});
  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with SingleTickerProviderStateMixin {
  static const _segments = PuzzleCategory.values;
  static const _segmentAngle = 360.0 / 6;

  double _rotation = 0;
  bool _isSpinning = false;
  PuzzleCategory? _landed;

  late AnimationController _spinController;
  late Animation<double> _spinAnim;

  final _rnd = math.Random();
  final _burstParticles = <_Particle>[];
  static const _burstColors = [
    Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.purple, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this);
    _spinController.addListener(() =>
        setState(() => _rotation = _spinAnim.value));
    _spinController.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onSpinComplete();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() { _isSpinning = true; _landed = null; });
    final target = _rotation +
        (5 + _rnd.nextDouble() * 5) * 360 + _rnd.nextDouble() * 360;
    _spinAnim = Tween<double>(begin: _rotation, end: target).animate(
        CurvedAnimation(parent: _spinController, curve: Curves.easeOut));
    _spinController.duration = const Duration(milliseconds: 3500);
    _spinController.forward(from: 0);
  }

  void _onSpinComplete() {
    final idx = (((360 - _rotation % 360) % 360) / _segmentAngle)
        .floor() % _segments.length;
    final landed = _segments[idx];
    setState(() { _isSpinning = false; _landed = landed; });
    final lang = context.read<LanguageProvider>().currentLanguage;
    context.read<TTSProvider>().speak(landed.title, lang.speechCode);
    _triggerBurst();
  }

  void _triggerBurst() {
    final size = MediaQuery.of(context).size;
    _burstParticles.clear();
    for (int i = 0; i < 32; i++) {
      final angle = _rnd.nextDouble() * 2 * math.pi;
      final speed = 60 + _rnd.nextDouble() * 140;
      _burstParticles.add(_Particle(
        x: size.width / 2, y: size.height * 0.4,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: _burstColors[_rnd.nextInt(_burstColors.length)],
        size: 8 + _rnd.nextDouble() * 12,
      ));
    }
    setState(() {});
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _burstParticles.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F5FF), Color(0xFFEFF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: OrientationBuilder(builder: (ctx, orientation) {
                final isTablet = MediaQuery.of(ctx).size.shortestSide > 600;
                final isLandscape = orientation == Orientation.landscape;
                return (isLandscape || isTablet)
                    ? _landscapeLayout()
                    : _portraitLayout();
              }),
            ),
            if (_burstParticles.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                      painter: _ParticlePainter(_burstParticles)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _portraitLayout() {
    return LayoutBuilder(builder: (_, c) {
      final isTablet = c.maxWidth > 600;
      return Column(
        children: [
          Text('Spin & Play!',
              style: TextStyle(
                  fontSize: isTablet ? 36 : 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Expanded(child: _wheelArea()),
          _spinButton(),
          const SizedBox(height: 12),
          if (_landed != null && !_isSpinning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _resultBanner(_landed!),
            ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _landscapeLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text('Spin & Play!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E))),
              Expanded(child: _wheelArea()),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _spinButton(),
                const SizedBox(height: 24),
                if (_landed != null && !_isSpinning)
                  _resultBanner(_landed!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _wheelArea() {
    return LayoutBuilder(builder: (_, c) {
      final wheelSize = math.min(c.maxWidth, c.maxHeight) * 0.88;
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _rotation * math.pi / 180,
              child: CustomPaint(
                size: Size(wheelSize, wheelSize),
                painter: _WheelPainter(_segments, _segmentAngle),
              ),
            ),
            Container(
              width: wheelSize * 0.18,
              height: wheelSize * 0.18,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 22))),
            ),
            Positioned(
              top: 0,
              child: CustomPaint(
                size: Size(wheelSize * 0.09, wheelSize * 0.09),
                painter: _TrianglePainter(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _spinButton() {
    return GestureDetector(
      onTap: _spin,
      child: AnimatedScale(
        scale: _isSpinning ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            gradient: _isSpinning
                ? null
                : const LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: _isSpinning ? Colors.grey : null,
            borderRadius: BorderRadius.circular(50),
            boxShadow: _isSpinning
                ? []
                : [
              BoxShadow(
                  color: Colors.purple.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSpinning ? Icons.hourglass_empty : Icons.refresh,
                color: Colors.white, size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                _isSpinning ? 'Spinning…' : 'SPIN!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultBanner(PuzzleCategory cat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                    color: cat.color, shape: BoxShape.circle),
                child: Center(
                    child: Text(cat.icon,
                        style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You got…',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(cat.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PuzzleGameScreen(category: cat)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: cat.color,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: cat.color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 24),
                    SizedBox(width: 6),
                    Text('Play!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wheel Painters & Static Helpers ───────────────────────────────────

class _WheelPainter extends CustomPainter {
  const _WheelPainter(this.segments, this.segmentAngle);
  final List<PuzzleCategory> segments;
  final double segmentAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final iconSize = (radius * 0.16).clamp(16.0, 40.0);
    final labelSize = (radius * 0.11).clamp(11.0, 22.0);

    for (int i = 0; i < segments.length; i++) {
      final startAngle = (segmentAngle * i - 90) * math.pi / 180;
      final sweepAngle = segmentAngle * math.pi / 180;
      final seg = segments[i];

      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, true,
          Paint()..color = seg.color);

      canvas.drawLine(center,
          Offset(center.dx + radius * math.cos(startAngle),
              center.dy + radius * math.sin(startAngle)),
          Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 2);

      final midAngle = startAngle + sweepAngle / 2;
      final dist = radius * 0.63;
      final pos = Offset(
          center.dx + dist * math.cos(midAngle),
          center.dy + dist * math.sin(midAngle));

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(midAngle + math.pi / 2);

      final iconTp = TextPainter(
        text: TextSpan(text: seg.icon, style: TextStyle(fontSize: iconSize)),
        textDirection: TextDirection.ltr,
      )..layout();
      iconTp.paint(canvas, Offset(-iconTp.width / 2, -iconTp.height - 4));

      final labelTp = TextPainter(
        text: TextSpan(
            text: seg.label,
            style: TextStyle(
                color: Colors.white,
                fontSize: labelSize,
                fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(-labelTp.width / 2, 4));

      canvas.restore();
    }

    canvas.drawCircle(center, radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(_WheelPainter _) => false;
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(path,
        Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _Particle {
  double x, y, vx, vy, size;
  Color color;
  _Particle({required this.x, required this.y, required this.vx,
    required this.vy, required this.color, required this.size});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
          Offset(p.x + p.vx * 0.3, p.y + p.vy * 0.3),
          p.size / 2,
          Paint()..color = p.color.withOpacity(0.75));
    }
  }
  @override
  bool shouldRepaint(_) => true;
}

// ── Puzzle Game Router with Feedback Provider ─────────────────────────

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({required this.category, super.key});
  final PuzzleCategory category;

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  final _feedback = PuzzleFeedbackController();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageProvider>().currentLanguage;

    return ChangeNotifierProvider.value(
      value: _feedback,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.category.title} Puzzle'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F5FF), Color(0xFFEFF8FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              SafeArea(child: _gameWidget(lang)),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _feedback,
                    builder: (_, __) => CustomPaint(
                      painter: PuzzleFeedbackOverlayPainter(_feedback.currentEffect),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameWidget(AppLanguage lang) {
    switch (widget.category) {
      case PuzzleCategory.alphabets:
        return AlphabetMatchGame(language: lang);
      case PuzzleCategory.numbers:
        return NumberBowlingGame(language: lang);
      case PuzzleCategory.shapes:
        return ShapeMatchGame(language: lang);
      case PuzzleCategory.colors:
        return ColorMatchGame(language: lang);
      case PuzzleCategory.trafficSigns:
        return TrafficSignMatchGame(language: lang);
      case PuzzleCategory.wordTest:
        return WordMatchGame(language: lang, category: Category.words);
    }
  }
}

// ── Shared Result Bar ─────────────────────────────────────────────────

class PuzzleResultBar extends StatelessWidget {
  const PuzzleResultBar({required this.correct, required this.total,
    required this.onRestart, super.key});
  final int correct, total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.08), blurRadius: 6)],
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
            const SizedBox(width: 8),
            Text('$correct / $total',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            GestureDetector(
              onTap: onRestart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(50)),
                child: const Row(children: [
                  Icon(Icons.refresh, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Again',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shape Silhouette Painters ─────────────────────────────────────────

class _DottedShapeWrapper extends CustomPainter {
  final String shapeKey;
  const _DottedShapeWrapper(this.shapeKey);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) * 0.85;
    final rect = Rect.fromLTWH(
        (size.width - side) / 2, (size.height - side) / 2, side, side);
    final path = ShapeFactory.path(shapeKey, rect);
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.06));
    canvas.drawPath(
        dashPath(path, dash: 12, gap: 10),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = Colors.grey.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(_DottedShapeWrapper o) => o.shapeKey != shapeKey;
}

class _SolidShapePainter extends CustomPainter {
  final String shapeKey;
  const _SolidShapePainter(this.shapeKey);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) * 0.85;
    final rect = Rect.fromLTWH(
        (size.width - side) / 2, (size.height - side) / 2, side, side);
    final path = ShapeFactory.path(shapeKey, rect);

    final paint = Paint()
      ..color = const Color(0xFF2DA882)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SolidShapePainter old) => old.shapeKey != shapeKey;
}

// ── 1. Shape Match ────────────────────────────────────────────────────

class ShapeMatchGame extends StatefulWidget {
  const ShapeMatchGame({required this.language, super.key});
  final AppLanguage language;

  @override
  State<ShapeMatchGame> createState() => _ShapeMatchGameState();
}

class _ShapeMatchGameState extends State<ShapeMatchGame> {
  List<TraceItem> _items = [];
  List<TraceItem> _opts = [];
  int _current = 0;
  int _correct = 0;
  bool _done = false;
  TraceItem? _chosen;

  static const int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    final all = ContentDataset.shapes(widget.language.id);
    final shuffled = List<TraceItem>.from(all)..shuffle();
    setState(() {
      _items = shuffled.take(_totalRounds).toList();
      _current = 0;
      _correct = 0;
      _chosen = null;
      _done = false;
    });
    _nextRound();
  }

  void _nextRound() {
    if (_current >= _items.length) {
      setState(() => _done = true);
      return;
    }

    final target = _items[_current];
    final all = ContentDataset.shapes(widget.language.id);
    final wrong = all.where((i) => i.shapeKey != target.shapeKey).toList()..shuffle();

    setState(() {
      _chosen = null;
      _opts = <TraceItem>[target, ...wrong.take(3)]..shuffle();
    });

    context.read<TTSProvider>().speak(target.spoken, widget.language.speechCode);
  }

  void _onSelect(TraceItem item, TapDownDetails details) {
    if (_chosen != null) return;
    setState(() => _chosen = item);

    final target = _items[_current];
    final isCorrect = item.shapeKey == target.shapeKey;
    if (isCorrect) setState(() => _correct++);

    context.read<PuzzleFeedbackController>().trigger(
      isCorrect: isCorrect,
      position: details.globalPosition,
      context: context,
      correctSpoken: target.spoken,
    );

    Future.delayed(Duration(milliseconds: isCorrect ? 2400 : 1400), () {
      if (!mounted) return;
      setState(() => _current++);
      _nextRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Center(
        child: PuzzleResultBar(
          correct: _correct,
          total: _totalRounds,
          onRestart: _restart,
        ),
      );
    }

    final target = _items[_current];

    return OrientationBuilder(builder: (ctx, orientation) {
      final isWide = orientation == Orientation.landscape ||
          MediaQuery.of(ctx).size.shortestSide > 600;

      final questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => context.read<TTSProvider>().speak(
                target.spoken, widget.language.speechCode),
            child: Container(
              width: isWide ? 150 : 135,
              height: isWide ? 150 : 135,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(110, 110),
                    painter: _DottedShapeWrapper(target.shapeKey ?? 'circle'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(Icons.volume_up_rounded,
                        color: Colors.grey.shade400, size: 22),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            target.display,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_current + 1} / $_totalRounds',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      );

      final optionsGrid = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isWide ? 2.2 : 1.25,
        ),
        itemCount: _opts.length,
        itemBuilder: (_, i) {
          final opt = _opts[i];
          final isSelected = _chosen == opt;
          final isTarget = opt.shapeKey == target.shapeKey;

          return GestureDetector(
            onTapDown: (d) => _onSelect(opt, d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? (isTarget ? Colors.green : Colors.redAccent)
                      : Colors.grey.shade200,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _SolidShapePainter(opt.shapeKey ?? 'circle'),
                  ),
                  if (_chosen != null && isTarget)
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 44),
                  if (isSelected && !isTarget)
                    const Icon(Icons.cancel_rounded,
                        color: Colors.redAccent, size: 44),
                ],
              ),
            ),
          );
        },
      );

      if (isWide) {
        return Row(
          children: [
            Expanded(flex: 2, child: Center(child: questionWidget)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: optionsGrid),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          const SizedBox(height: 12),
          Expanded(flex: 3, child: Center(child: questionWidget)),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: optionsGrid,
            ),
          ),
        ],
      );
    });
  }
}

// ── 2. Color Match ────────────────────────────────────────────────────

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({required this.language, super.key});
  final AppLanguage language;

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  List<TraceItem> _items = [];
  List<TraceItem> _opts = [];
  int _current = 0;
  int _correct = 0;
  bool _done = false;
  TraceItem? _chosen;

  static const int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    final all = ContentDataset.items(widget.language.id, Category.colors);
    final shuffled = List<TraceItem>.from(all)..shuffle();
    setState(() {
      _items = shuffled.take(_totalRounds).toList();
      _current = 0;
      _correct = 0;
      _chosen = null;
      _done = false;
    });
    _nextRound();
  }

  void _nextRound() {
    if (_current >= _items.length) {
      setState(() => _done = true);
      return;
    }

    final target = _items[_current];
    final all = ContentDataset.items(widget.language.id, Category.colors);
    final wrong = all.where((i) => i.colorKey != target.colorKey).toList()..shuffle();

    setState(() {
      _chosen = null;
      _opts = <TraceItem>[target, ...wrong.take(3)]..shuffle();
    });

    context.read<TTSProvider>().speak(target.spoken, widget.language.speechCode);
  }

  void _onSelect(TraceItem item, TapDownDetails details) {
    if (_chosen != null) return;
    setState(() => _chosen = item);

    final target = _items[_current];
    final isCorrect = item.colorKey == target.colorKey;
    if (isCorrect) setState(() => _correct++);

    context.read<PuzzleFeedbackController>().trigger(
      isCorrect: isCorrect,
      position: details.globalPosition,
      context: context,
      correctSpoken: target.spoken,
    );

    Future.delayed(Duration(milliseconds: isCorrect ? 2400 : 1400), () {
      if (!mounted) return;
      setState(() => _current++);
      _nextRound();
    });
  }

  Color _getColor(String? key) {
    return Color(itemColorMap[key ?? ''] ?? 0xFF888888);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Center(
        child: PuzzleResultBar(
          correct: _correct,
          total: _totalRounds,
          onRestart: _restart,
        ),
      );
    }

    final target = _items[_current];

    return OrientationBuilder(builder: (ctx, orientation) {
      final isWide = orientation == Orientation.landscape ||
          MediaQuery.of(ctx).size.shortestSide > 600;

      final questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => context.read<TTSProvider>().speak(
                target.spoken, widget.language.speechCode),
            child: Container(
              width: isWide ? 140 : 130,
              height: isWide ? 140 : 130,
              decoration: BoxDecoration(
                color: _getColor(target.colorKey),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: _getColor(target.colorKey).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.volume_up_rounded, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            target.display,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_current + 1} / $_totalRounds',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      );

      final optionsGrid = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isWide ? 2.2 : 1.3,
        ),
        itemCount: _opts.length,
        itemBuilder: (_, i) {
          final opt = _opts[i];
          final color = _getColor(opt.colorKey);
          final isSelected = _chosen == opt;
          final isTarget = opt.colorKey == target.colorKey;

          return GestureDetector(
            onTapDown: (d) => _onSelect(opt, d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? (isTarget ? Colors.greenAccent : Colors.redAccent)
                      : Colors.white,
                  width: isSelected ? 5 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_chosen != null && isTarget)
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 42),
                  if (isSelected && !isTarget)
                    const Icon(Icons.cancel_rounded,
                        color: Colors.white, size: 42),
                ],
              ),
            ),
          );
        },
      );

      if (isWide) {
        return Row(
          children: [
            Expanded(flex: 2, child: Center(child: questionWidget)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: optionsGrid),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          const SizedBox(height: 12),
          Expanded(flex: 3, child: Center(child: questionWidget)),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: optionsGrid,
            ),
          ),
        ],
      );
    });
  }
}

// ── 3. Traffic Sign Match ─────────────────────────────────────────────

class TrafficSignMatchGame extends StatefulWidget {
  const TrafficSignMatchGame({required this.language, super.key});
  final AppLanguage language;

  @override
  State<TrafficSignMatchGame> createState() => _TrafficSignMatchGameState();
}

class _TrafficSignMatchGameState extends State<TrafficSignMatchGame> {
  List<TraceItem> _pairs = [];
  List<TraceItem> _opts = [];
  int _current = 0;
  int _correct = 0;
  bool _done = false;
  TraceItem? _chosen;

  static const int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    final all = ContentDataset.trafficSigns(widget.language.id);
    final shuffled = List<TraceItem>.from(all)..shuffle();
    setState(() {
      _pairs = shuffled.take(_totalRounds).toList();
      _current = 0;
      _correct = 0;
      _chosen = null;
      _done = false;
    });
    _buildOptions();
  }

  void _buildOptions() {
    if (_current >= _pairs.length) return;
    final target = _pairs[_current];
    final all = ContentDataset.trafficSigns(widget.language.id);
    final wrong = all.where((i) => i.display != target.display).toList()..shuffle();
    setState(() {
      _chosen = null;
      _opts = <TraceItem>[target, ...wrong.take(3)]..shuffle();
    });
    context.read<TTSProvider>().speak(target.spoken, widget.language.speechCode);
  }

  void _onAnswer(TraceItem opt, TapDownDetails details) {
    if (_chosen != null) return;
    setState(() => _chosen = opt);

    final target = _pairs[_current];
    final isRight = opt.display == target.display;
    if (isRight) setState(() => _correct++);

    context.read<PuzzleFeedbackController>().trigger(
      isCorrect: isRight,
      position: details.globalPosition,
      context: context,
      correctSpoken: target.display,
    );

    Future.delayed(Duration(milliseconds: isRight ? 2400 : 1400), () {
      if (!mounted) return;
      setState(() { _chosen = null; _current++; });
      if (_current >= _pairs.length) {
        setState(() => _done = true);
        return;
      }
      _buildOptions();
    });
  }

  String _signKeyOf(TraceItem item) =>
      (item.shapeKey ?? '').replaceFirst('traffic_', '');

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Center(
        child: PuzzleResultBar(
          correct: _correct,
          total: _totalRounds,
          onRestart: _restart,
        ),
      );
    }

    final target = _pairs[_current];

    return OrientationBuilder(builder: (ctx, orientation) {
      final isWide = orientation == Orientation.landscape ||
          MediaQuery.of(ctx).size.shortestSide > 600;

      final questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
            ),
            child: TrafficSignWidget(signKey: _signKeyOf(target), label: '', size: 120),
          ),
          const SizedBox(height: 10),
          Text(
            target.display,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${_current + 1} / $_totalRounds',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      );

      final optionsGrid = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isWide ? 2.2 : 1.25,
        ),
        itemCount: _opts.length,
        itemBuilder: (_, i) {
          final opt = _opts[i];
          final isSelected = _chosen == opt;
          final isTarget = opt.display == target.display;

          return GestureDetector(
            onTapDown: (d) => _onAnswer(opt, d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isTarget ? Colors.green : Colors.redAccent)
                      : Colors.grey.shade200,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: TrafficSignWidget(
                      signKey: _signKeyOf(opt),
                      label: '',
                      size: 65,
                    ),
                  ),
                  if (_chosen != null && isTarget)
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 44),
                  if (isSelected && !isTarget)
                    const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 44),
                ],
              ),
            ),
          );
        },
      );

      if (isWide) {
        return Row(
          children: [
            Expanded(flex: 2, child: Center(child: questionWidget)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: optionsGrid),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          const SizedBox(height: 12),
          Expanded(flex: 3, child: Center(child: questionWidget)),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: optionsGrid,
            ),
          ),
        ],
      );
    });
  }
}

// ── 4. Word Match ─────────────────────────────────────────────────────

class WordMatchGame extends StatefulWidget {
  const WordMatchGame({
    required this.language,
    required this.category,
    super.key,
  });

  final AppLanguage language;
  final Category category;

  @override
  State<WordMatchGame> createState() => _WordMatchGameState();
}

class _WordMatchGameState extends State<WordMatchGame> {
  List<TraceItem> _items = [];
  List<TraceItem> _opts = [];
  int _current = 0;
  int _correct = 0;
  bool _done = false;
  TraceItem? _chosen;

  static const int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    final all = ContentDataset.items(widget.language.id, widget.category);
    final shuffled = List<TraceItem>.from(all)..shuffle();
    setState(() {
      _items = shuffled.take(_totalRounds).toList();
      _current = 0;
      _correct = 0;
      _chosen = null;
      _done = false;
    });
    _nextRound();
  }

  void _nextRound() {
    if (_current >= _items.length) {
      setState(() => _done = true);
      return;
    }

    final target = _items[_current];
    final all = ContentDataset.items(widget.language.id, widget.category);
    final wrong = all.where((i) => i.display != target.display).toList()..shuffle();

    setState(() {
      _chosen = null;
      _opts = <TraceItem>[target, ...wrong.take(3)]..shuffle();
    });

    context.read<TTSProvider>().speak(target.spoken, widget.language.speechCode);
  }

  void _onSelect(TraceItem item, TapDownDetails details) {
    if (_chosen != null) return;
    setState(() => _chosen = item);

    final target = _items[_current];
    final isCorrect = item.display == target.display;
    if (isCorrect) setState(() => _correct++);

    context.read<PuzzleFeedbackController>().trigger(
      isCorrect: isCorrect,
      position: details.globalPosition,
      context: context,
      correctSpoken: target.display,
    );

    Future.delayed(Duration(milliseconds: isCorrect ? 2400 : 1400), () {
      if (!mounted) return;
      setState(() => _current++);
      _nextRound();
    });
  }

  Widget _buildItemVisual(TraceItem item, {double size = 64}) {
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      return Image.asset(
        item.imagePath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackVisual(item, size),
      );
    }
    return _fallbackVisual(item, size);
  }

  Widget _fallbackVisual(TraceItem item, double size) {
    return Text(
      item.display.characters.first,
      style: TextStyle(
        fontSize: size * 0.7,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF7C5CDB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Center(
        child: PuzzleResultBar(
          correct: _correct,
          total: _totalRounds,
          onRestart: _restart,
        ),
      );
    }

    final target = _items[_current];

    return OrientationBuilder(builder: (ctx, orientation) {
      final isWide = orientation == Orientation.landscape ||
          MediaQuery.of(ctx).size.shortestSide > 600;

      final questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => context.read<TTSProvider>().speak(
                target.spoken, widget.language.speechCode),
            child: Container(
              width: isWide ? 130 : 120,
              height: isWide ? 130 : 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.volume_up_rounded, color: Colors.white, size: 54),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            target.display,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_current + 1} / $_totalRounds',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      );

      final optionsGrid = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isWide ? 2.2 : 1.25,
        ),
        itemCount: _opts.length,
        itemBuilder: (_, i) {
          final opt = _opts[i];
          final isSelected = _chosen == opt;
          final isTarget = opt.display == target.display;

          return GestureDetector(
            onTapDown: (d) => _onSelect(opt, d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? (isTarget ? Colors.green : Colors.redAccent)
                      : Colors.grey.shade200,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Center(child: _buildItemVisual(opt))),
                      const SizedBox(height: 4),
                      Text(
                        opt.display,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (_chosen != null && isTarget)
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 44),
                  if (isSelected && !isTarget)
                    const Icon(Icons.cancel_rounded,
                        color: Colors.redAccent, size: 44),
                ],
              ),
            ),
          );
        },
      );

      if (isWide) {
        return Row(
          children: [
            Expanded(flex: 2, child: Center(child: questionWidget)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: optionsGrid),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          const SizedBox(height: 12),
          Expanded(flex: 3, child: Center(child: questionWidget)),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: optionsGrid,
            ),
          ),
        ],
      );
    });
  }
}

// ── 5. Number Bowling ─────────────────────────────────────────────────

class NumberBowlingGame extends StatefulWidget {
  const NumberBowlingGame({required this.language, super.key});
  final AppLanguage language;
  @override State<NumberBowlingGame> createState() => _NumberBowlingGameState();
}

class _NumberBowlingGameState extends State<NumberBowlingGame> {
  int _target = 0;
  Set<int> _tapped = {};
  int _correct = 0, _round = 0;
  bool _done = false;
  static const _total = 5, _maxPins = 10;
  final _rnd = math.Random();

  @override void initState() { super.initState(); _restart(); }

  void _restart() {
    setState(() { _correct = 0; _round = 0; _done = false; });
    _next();
  }

  void _next() {
    setState(() { _tapped = {}; _target = 1 + _rnd.nextInt(_maxPins); });
    context.read<TTSProvider>().speak('$_target', widget.language.speechCode);
  }

  void _check(TapDownDetails details) {
    final isRight = _tapped.length == _target;
    if (isRight) setState(() => _correct++);

    context.read<PuzzleFeedbackController>().trigger(
      isCorrect: isRight,
      position: details.globalPosition,
      context: context,
      correctSpoken: '$_target',
    );

    setState(() => _round++);
    if (_round >= _total) {
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) setState(() => _done = true);
      });
      return;
    }
    Future.delayed(const Duration(milliseconds: 1100), _next);
  }

  Widget _pinRow(List<int> pins) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: pins.map((pin) {
      final hit = _tapped.contains(pin);
      return GestureDetector(
        onTap: () {
          setState(() {
            if (hit) {
              _tapped.remove(pin);
            } else if (_tapped.length < _target) {
              _tapped.add(pin);
              context.read<TTSProvider>().speak('${_tapped.length}', widget.language.speechCode);
            }
          });
        },
        child: AnimatedScale(
          scale: hit ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
                hit ? Icons.adjust : Icons.radio_button_unchecked,
                size: 34,
                color: hit ? Colors.grey : Colors.orange),
          ),
        ),
      );
    }).toList(),
  );

  @override
  Widget build(BuildContext context) {
    if (_done) return Center(child: PuzzleResultBar(
        correct: _correct, total: _total, onRestart: _restart));

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Knock down $_target pins!',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900)),
        Text('$_target',
            style: const TextStyle(
                fontSize: 72, fontWeight: FontWeight.w900,
                color: Colors.orange)),
        const SizedBox(height: 8),
        GestureDetector(
          onTapDown: _check,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: const Text('Check!',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text('Round ${_round + 1} of $_total',
            style: const TextStyle(color: Colors.grey)),
      ],
    );

    final pins = Column(children: [
      _pinRow([1]),
      _pinRow([2, 3]),
      _pinRow([4, 5, 6]),
      _pinRow([7, 8, 9, 10]),
    ]);

    return OrientationBuilder(builder: (ctx, orientation) {
      final isWide = orientation == Orientation.landscape ||
          MediaQuery.of(ctx).size.shortestSide > 600;
      if (isWide) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: Center(child: info)),
            Expanded(child: Center(child: pins)),
          ],
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [info, const SizedBox(height: 16), pins],
      );
    });
  }
}

// ── 6. Alphabet Match ─────────────────────────────────────────────────

class AlphabetMatchGame extends StatefulWidget {
  const AlphabetMatchGame({required this.language, super.key});
  final AppLanguage language;
  @override State<AlphabetMatchGame> createState() => _AlphabetMatchGameState();
}

class _AlphabetMatchGameState extends State<AlphabetMatchGame> {
  static const _imageMap = {
    'A':'Apple','B':'Ball','C':'Cat','D':'Dog','E':'Egg',
    'F':'Fish','G':'Giraffe','H':'House','I':'Igloo','J':'Jellyfish',
    'K':'Kangaroo','L':'Lion','M':'Monkey','N':'Nest','O':'Octopus',
    'P':'Panda','Q':'Queen','R':'Rabbit','S':'Sun','T':'Tree',
    'U':'Umbrella','V':'Violin','W':'Whale','X':'Xylophone',
    'Y':'Yak','Z':'Zebra',
  };

  List<(String, String)> _pairs = [];
  Map<String, String?> _answers = {};
  String? _selectedTile;
  int _correct = 0;
  bool _done = false;

  @override void initState() { super.initState(); _restart(); }

  void _restart() {
    final letters = _imageMap.keys.toList()..shuffle();
    final picked = letters.take(5).toList();
    setState(() {
      _pairs = picked.map((l) => (l, _imageMap[l]!)).toList();
      _answers = {for (final p in _pairs) p.$2: null};
      _selectedTile = null;
      _correct = 0;
      _done = false;
    });
  }

  void _drop(String letter, String image, Offset dropPos) {
    final pair = _pairs.firstWhere((p) => p.$2 == image);
    final isCorrect = letter == pair.$1;

    if (isCorrect) {
      setState(() {
        _answers[image] = letter;
        if (_selectedTile == letter) _selectedTile = null;
        _correct++;
      });
    }

    context.read<PuzzleFeedbackController>().trigger(
      isCorrect: isCorrect,
      position: dropPos,
      context: context,
      correctSpoken: pair.$2,
    );

    if (_answers.values.every((v) => v != null)) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _done = true);
      });
    }
  }

  Widget _tile(String letter, {bool dragging = false, bool ghost = false}) {
    final isTapped = _selectedTile == letter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTile = isTapped ? null : letter;
        });
        context.read<TTSProvider>().speak(letter, widget.language.speechCode);
      },
      child: Container(
        width: 48, height: 48,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: ghost
              ? Colors.grey.shade200
              : isTapped
              ? Colors.purple
              : dragging ? Colors.blue.shade700 : Colors.blue,
          borderRadius: BorderRadius.circular(10),
          border: isTapped ? Border.all(color: Colors.white, width: 2.5) : null,
          boxShadow: ghost ? [] : [
            BoxShadow(
              color: (isTapped ? Colors.purple : Colors.blue).withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(letter,
            style: TextStyle(
                color: ghost ? Colors.grey : Colors.white,
                fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Center(child: PuzzleResultBar(
          correct: _correct, total: _pairs.length, onRestart: _restart));
    }

    final remaining = _pairs
        .where((p) => _answers[p.$2] != p.$1)
        .map((p) => p.$1).toList()..shuffle();

    return OrientationBuilder(builder: (ctx, orientation) {
      final isWide = orientation == Orientation.landscape ||
          MediaQuery.of(ctx).size.shortestSide > 600;

      return Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: isWide ? 5 : 3,
              padding: const EdgeInsets.all(10),
              crossAxisSpacing: 10, mainAxisSpacing: 10,
              children: _pairs.map((pair) {
                final placed = _answers[pair.$2];
                final isCorrect = placed == pair.$1;

                return GestureDetector(
                  onTapDown: (details) {
                    if (_selectedTile != null) {
                      _drop(_selectedTile!, pair.$2, details.globalPosition);
                    } else {
                      context.read<TTSProvider>().speak(pair.$2, widget.language.speechCode);
                    }
                  },
                  child: DragTarget<String>(
                    onAcceptWithDetails: (d) => _drop(d.data, pair.$2, d.offset),
                    builder: (_, candidates, __) {
                      final isHovered = candidates.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.blue.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCorrect ? Colors.green
                                : isHovered ? Colors.blue
                                : (_selectedTile != null && !isCorrect)
                                ? Colors.purple.shade200
                                : Colors.grey.shade200,
                            width: (isCorrect || isHovered) ? 2.5 : 1,
                          ),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 4)],
                        ),
                        child: Column(children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/${pair.$1}/${pair.$2}.png',
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(pair.$1,
                                          style: TextStyle(
                                              fontSize: isWide ? 52 : 44,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.blue.shade300)),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(pair.$1,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(pair.$2,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Container(
                            height: 30, width: double.infinity,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.12)
                                  : isHovered
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCorrect ? Colors.green
                                    : isHovered ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: placed != null
                                ? Text(placed,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.orange))
                                : Icon(Icons.arrow_downward,
                                size: 14, color: Colors.grey.shade400),
                          ),
                        ]),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: remaining.map((letter) => Draggable<String>(
                data: letter,
                feedback: Material(
                    color: Colors.transparent,
                    child: _tile(letter, dragging: true)),
                childWhenDragging: _tile(letter, ghost: true),
                child: _tile(letter),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}