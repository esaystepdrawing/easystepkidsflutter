import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cbn_models.dart';
import 'cbn_strings.dart';
import 'connect_dots_data.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

/// Connect the Dots: numbered dots (in the language's digits) around a
/// picture's outline. Draw from dot to dot in order; the picture appears.
class ConnectDotsScreen extends StatefulWidget {
  final KidsLanguage language;

  const ConnectDotsScreen({super.key, this.language = KidsLanguage.english});

  @override
  State<ConnectDotsScreen> createState() => _ConnectDotsScreenState();
}

class _ConnectDotsScreenState extends State<ConnectDotsScreen> {
  final _random = math.Random();
  bool _loading = true;
  int _level = 3;
  int _round = 0;
  String _subject = 'apple';
  List<Offset> _dots = [];
  int _joined = 0;
  bool _finished = false;
  Offset? _finger;
  final List<KidsBurst> _bursts = [];

  KidsLanguage get _lang => widget.language;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final level = await KidsAge.load();
    await KidsGamePictures.load();
    await KidsGameSound.instance.start();
    if (!mounted) return;
    setState(() {
      _level = level;
      _loading = false;
      _newGame();
    });
  }

  @override
  void dispose() {
    KidsGameSound.instance.stop();
    KidsGameServices.stopSpeaking();
    super.dispose();
  }

  /// 10 / 15 / 20 dots by age, but never more than the language has number words for.
  int get _dotCount {
    final wanted = _level <= 3 ? 10 : (_level == 4 ? 15 : 20);
    final available = math.max(_lang.numberDisplay.length - 1, 10);
    for (final n in const [20, 15, 10]) {
      if (n <= wanted && n <= available) return n;
    }
    return 10;
  }

  void _newGame() {
    _round++;
    final count = _dotCount;
    final options = (ConnectDotsData.subjects[count] ?? const <String>[])
        .where((s) => s != _subject && KidsGamePictures.bySubject.containsKey(s))
        .toList();
    if (options.isNotEmpty) _subject = options[_random.nextInt(options.length)];
    _dots = ConnectDotsData.dots[_subject]?[count] ?? const [];
    _joined = 0;
    _finished = false;
    _finger = null;
    _bursts.clear();
  }

  void _setLevel(int level) {
    if (level == _level) return;
    KidsAge.set(level);
    setState(() {
      _level = level;
      _newGame();
    });
  }

  // MARK: - Geometry

  Rect _frame(Size size) {
    final side = math.min(size.width, size.height);
    return Rect.fromLTWH((size.width - side) / 2, (size.height - side) / 2, side, side);
  }

  /// Same fit as KidsGamePicture inside the inner 80% box, so dots sit on the picture.
  List<Offset> _screenDots(Size size) {
    final page = KidsGamePictures.bySubject[_subject];
    if (page == null) return const [];
    final frame = _frame(size);
    final box = frame.deflate(frame.width * 0.1);
    final fit = CbnFit.of(page.contentBounds, box.size);
    return _dots.map((p) => fit.toScreen(p) + box.topLeft).toList();
  }

  // MARK: - Touch

  void _touch(Offset location, Size size) {
    setState(() => _finger = location);
    final points = _screenDots(size);
    if (_finished || _joined >= points.length) return;
    final radius = math.max(26.0, _frame(size).width * 0.06);
    if ((location - points[_joined]).distance >= radius) return;

    setState(() => _joined++);
    KidsGameSound.instance.pop();
    HapticFeedback.selectionClick();
    _lang.speak(_lang.numberWord(_joined));

    if (_joined == points.length) _finish(size);
  }

  void _finish(Size size) {
    final round = _round;
    setState(() => _finished = true);
    KidsGameSound.instance.jingle();
    HapticFeedback.heavyImpact();
    for (var i = 0; i < 5; i++) {
      final burst = KidsBurst(
        center: Offset((0.15 + _random.nextDouble() * 0.7) * size.width, (0.15 + _random.nextDouble() * 0.7) * size.height),
        colors: KidsGamePictures.colors(_subject),
        count: 22,
        distance: 160,
      );
      _bursts.add(burst);
      Timer(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => _bursts.removeWhere((b) => b.id == burst.id));
      });
    }
    final name = KidsGamePictures.title(_subject, _lang.id);
    Timer(const Duration(milliseconds: 600), () {
      if (!mounted || round != _round) return;
      _lang.speak('${CbnStrings.praiseFor(_lang.id)} $name');
    });
    Timer(const Duration(milliseconds: 3600), () {
      if (!mounted || round != _round) return;
      setState(_newGame);
    });
  }

  // MARK: - UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          KidsAgeMenu(level: _level, onSelect: _setLevel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(_newGame)),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFFFFAF0), Color(0xFFF0FAFF)],
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(builder: (context, c) => _board(Size(c.maxWidth, c.maxHeight))),
                ),
        ),
      ),
    );
  }

  Widget _board(Size size) {
    final frame = _frame(size);
    final page = KidsGamePictures.bySubject[_subject];
    final points = _screenDots(size);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => _touch(d.localPosition, size),
      onPanUpdate: (d) => _touch(d.localPosition, size),
      onPanEnd: (_) => setState(() => _finger = null),
      onTapDown: (d) => _touch(d.localPosition, size),
      onTapUp: (_) => setState(() => _finger = null),
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: frame,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
            ),
          ),
          // the picture fades in when the last dot is joined
          if (page != null)
            Positioned.fromRect(
              rect: frame.deflate(frame.width * 0.1),
              child: AnimatedOpacity(
                opacity: _finished ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: KidsGamePicture(page: page),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DotsPainter(
                  points: points,
                  joined: _joined,
                  finished: _finished,
                  finger: _finger,
                  label: _lang.numberText,
                ),
              ),
            ),
          ),
          Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final List<Offset> points;
  final int joined;
  final bool finished;
  final Offset? finger;
  final String Function(int) label;

  _DotsPainter({
    required this.points,
    required this.joined,
    required this.finished,
    required this.finger,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // lines joined so far
    if (joined > 0) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < math.min(joined, points.length); i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      if (finished) path.close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.orange,
      );

      // a stretchy line from the last dot to the finger
      final f = finger;
      if (!finished && f != null) {
        canvas.drawLine(
          points[joined - 1],
          f,
          Paint()
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..color = Colors.orange.withOpacity(0.4),
        );
      }
    }

    if (finished) return;

    // dots and numbers; numbers sit outside the shape, away from its middle
    var cx = 0.0, cy = 0.0;
    for (final p in points) {
      cx += p.dx;
      cy += p.dy;
    }
    final center = Offset(cx / points.length, cy / points.length);

    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final isNext = i == joined;
      final done = i < joined;
      canvas.drawCircle(
        p,
        isNext ? 13 : 8,
        Paint()..color = isNext ? Colors.green : (done ? Colors.orange : const Color(0xFF404040)),
      );

      final dir = p - center;
      final len = math.max(1.0, dir.distance);
      final at = p + dir / len * 22;
      final tp = TextPainter(
        text: TextSpan(
          text: label(i + 1),
          style: TextStyle(
            fontSize: isNext ? 20 : 15,
            fontWeight: FontWeight.w900,
            color: isNext ? Colors.green : const Color(0xFF4D4D4D),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => true;
}
