import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cbn_models.dart';
import 'cbn_strings.dart';

// Shared by Color by Number, Shadow Match and Maze:
// the child's age, the pictures, sparkle bursts, the scatter effect,
// a shake helper and synthesized sounds.

// MARK: - Child's age

class KidsAge {
  static const levels = [3, 4, 5];
  static const _key = 'colorByNumberLevel';
  static int _current = 3;

  static int get current => _current;

  static Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_key) ?? 3;
    _current = levels.contains(saved) ? saved : 3;
    return _current;
  }

  static Future<void> set(int level) async {
    _current = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, level);
  }
}

class KidsAgeMenu extends StatelessWidget {
  final int level;
  final ValueChanged<int> onSelect;

  const KidsAgeMenu({super.key, required this.level, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: onSelect,
      itemBuilder: (context) => KidsAge.levels
          .map((value) => PopupMenuItem<int>(
                value: value,
                child: Row(children: [
                  SizedBox(width: 24, child: value == level ? const Icon(Icons.check, size: 18) : null),
                  Text('Age $value'),
                ]),
              ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person, size: 20),
          const SizedBox(width: 2),
          Text('$level', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// MARK: - Pictures (the age 3 coloring drawings)

class KidsGamePictures {
  static Map<String, CbnPage> bySubject = {};

  static Future<void> load() async {
    if (bySubject.isNotEmpty) return;
    final all = await CbnLibrary.loadAll();
    bySubject = {for (final p in all.where((p) => p.level == 3)) p.subject: p};
  }

  static String title(String subject, String languageId) =>
      CbnStrings.title(subject, languageId) ??
      bySubject[subject]?.title ??
      (subject.isEmpty ? subject : subject[0].toUpperCase() + subject.substring(1));

  static List<Color> colors(String subject) =>
      [...?bySubject[subject]?.palette.map((p) => p.color), Colors.yellow, Colors.orange];
}

class KidsPicturePainter extends CustomPainter {
  final CbnPage page;
  final bool shadow;

  KidsPicturePainter(this.page, {this.shadow = false});

  @override
  void paint(Canvas canvas, Size size) {
    final fit = CbnFit.of(page.contentBounds, size);
    canvas.save();
    canvas.translate(fit.offset.dx, fit.offset.dy);
    canvas.scale(fit.scale);
    cbnPaintPage(canvas, page, allColored: !shadow, shadow: shadow);
    canvas.restore();
  }

  @override
  bool shouldRepaint(KidsPicturePainter old) => old.page != page || old.shadow != shadow;
}

/// A subject drawn fully colored, or as a solid shadow.
class KidsGamePicture extends StatelessWidget {
  final CbnPage page;
  final bool shadow;

  const KidsGamePicture({super.key, required this.page, this.shadow = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: CustomPaint(painter: KidsPicturePainter(page, shadow: shadow)));
  }
}

// MARK: - Shake (wrong answer)

/// Shakes its child sideways every time [trigger] changes.
class KidsShake extends StatefulWidget {
  final int trigger;
  final Widget child;

  const KidsShake({super.key, required this.trigger, required this.child});

  @override
  State<KidsShake> createState() => _KidsShakeState();
}

class _KidsShakeState extends State<KidsShake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  @override
  void didUpdateWidget(KidsShake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(8 * math.sin(_controller.value * math.pi * 4), 0),
        child: child,
      ),
    );
  }
}

// MARK: - Sparkle bursts

class KidsBurst {
  static int _nextId = 0;
  final int id = _nextId++;
  final Offset center;
  final List<Color> colors;
  final int count;
  final double distance;

  KidsBurst({required this.center, required this.colors, this.count = 18, this.distance = 110});
}

class _BurstPiece {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final bool sparkle;
  final double spin;

  _BurstPiece(this.angle, this.distance, this.size, this.color, this.sparkle, this.spin);
}

class KidsBurstView extends StatefulWidget {
  final KidsBurst burst;

  const KidsBurstView({super.key, required this.burst});

  @override
  State<KidsBurstView> createState() => _KidsBurstViewState();
}

class _KidsBurstViewState extends State<KidsBurstView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  late final List<_BurstPiece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    final b = widget.burst;
    _pieces = List.generate(b.count, (i) {
      return _BurstPiece(
        r.nextDouble() * math.pi * 2,
        b.distance * (0.45 + r.nextDouble() * 0.55),
        12 + r.nextDouble() * 12,
        b.colors.isEmpty ? Colors.yellow : b.colors[r.nextInt(b.colors.length)],
        i % 3 != 2,
        (r.nextDouble() - 0.5) * 7,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _BurstPainter(
            widget.burst.center,
            _pieces,
            Curves.easeOut.transform(_controller.value),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final Offset center;
  final List<_BurstPiece> pieces;
  final double t;

  _BurstPainter(this.center, this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      paint.color = p.color.withOpacity((1 - t).clamp(0.0, 1.0));
      final pos = center + Offset(math.cos(p.angle), math.sin(p.angle)) * (p.distance * t);
      final s = p.size * (1 + 0.4 * t);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.sparkle) {
        // four-pointed sparkle
        final path = Path();
        for (var k = 0; k < 8; k++) {
          final radius = k.isEven ? s / 2 : s * 0.14;
          final a = k * math.pi / 4 - math.pi / 2;
          final pt = Offset(math.cos(a) * radius, math.sin(a) * radius);
          if (k == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset.zero, s * 0.3, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}

class KidsBurstLayer extends StatelessWidget {
  final List<KidsBurst> bursts;

  const KidsBurstLayer({super.key, required this.bursts});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final b in bursts) Positioned.fill(child: KidsBurstView(key: ValueKey(b.id), burst: b)),
        ],
      ),
    );
  }
}

// MARK: - Scatter: a picture breaks into 9 pieces that fly apart

class KidsScatterView extends StatefulWidget {
  final CbnPage page;

  const KidsScatterView({super.key, required this.page});

  @override
  State<KidsScatterView> createState() => _KidsScatterViewState();
}

class _KidsScatterViewState extends State<KidsScatterView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  late final List<List<double>> _moves; // dx, dy, spin per piece

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _moves = List.generate(9, (i) {
      final row = i ~/ 3, col = i % 3;
      return [
        (col - 1) * (0.8 + r.nextDouble() * 0.7) + (r.nextDouble() - 0.5) * 0.8,
        (row - 1) * (0.8 + r.nextDouble() * 0.7) + (r.nextDouble() * 0.8 - 0.6),
        (r.nextDouble() - 0.5) * 8,
      ];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ScatterPainter(widget.page, _moves, Curves.easeOut.transform(_controller.value)),
        ),
      ),
    );
  }
}

class _ScatterPainter extends CustomPainter {
  final CbnPage page;
  final List<List<double>> moves;
  final double t;

  _ScatterPainter(this.page, this.moves, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 3, h = size.height / 3;
    final fit = CbnFit.of(page.contentBounds, size);
    for (var i = 0; i < 9; i++) {
      final row = i ~/ 3, col = i % 3;
      final piece = Rect.fromLTWH(col * w, row * h, w, h);
      final m = moves[i];
      canvas.save();
      canvas.translate(m[0] * size.width * 1.8 * t, m[1] * size.height * 1.8 * t);
      canvas.translate(piece.center.dx, piece.center.dy);
      canvas.rotate(m[2] * t);
      canvas.translate(-piece.center.dx, -piece.center.dy);
      canvas.clipRect(piece);
      canvas.saveLayer(piece, Paint()..color = Colors.white.withOpacity((1 - t * 0.85).clamp(0.0, 1.0)));
      canvas.translate(fit.offset.dx, fit.offset.dy);
      canvas.scale(fit.scale);
      cbnPaintPage(canvas, page, allColored: true);
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ScatterPainter old) => old.t != t;
}

// MARK: - Sounds (synthesized, no audio files needed)

enum KidsMotion { wind, engine }

/// Short tunes for matches and wins, plus a looping wind or engine sound that
/// plays while the child is moving and fades out when they stop.
class KidsGameSound {
  KidsGameSound._();

  static final KidsGameSound instance = KidsGameSound._();

  static const int _rate = 22050;
  final List<AudioPlayer> _effects = [];
  int _nextEffect = 0;
  AudioPlayer? _motionPlayer;
  KidsMotion _motion = KidsMotion.wind;
  bool _motionPlaying = false;
  double _motionVolume = 0;
  Timer? _decay;
  final Map<String, Uint8List> _cache = {};

  Future<void> start() async {
    if (_effects.isEmpty) {
      for (var i = 0; i < 4; i++) {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        _effects.add(player);
      }
    }
    if (_motionPlayer == null) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      _motionPlayer = player;
    }
  }

  Future<void> stop() async {
    _decay?.cancel();
    _decay = null;
    _motionPlaying = false;
    _motionVolume = 0;
    await _motionPlayer?.stop();
    for (final p in _effects) {
      await p.stop();
    }
  }

  // Effects

  void pop() => _play('pop', () => _tones([[12, 0, 0.08]], 0.18));

  void chime() => _play('chime', () => _tones([[0, 0, 0.25], [4, 0.08, 0.25], [7, 0.16, 0.25], [12, 0.24, 0.5]]));

  void boop() => _play('boop', () => _tones([[-5, 0, 0.18], [-8, 0.14, 0.28]], 0.25));

  void jingle() => _play(
      'jingle',
      () => _tones([
            [0, 0, 0.18], [4, 0.15, 0.18], [7, 0.30, 0.18], [12, 0.45, 0.35],
            [7, 0.78, 0.15], [12, 0.93, 0.7], [16, 0.93, 0.7], [4, 0.93, 0.7],
          ]));

  void _play(String key, Uint8List Function() build) {
    if (_effects.isEmpty) return;
    final bytes = _cache.putIfAbsent(key, build);
    final player = _effects[_nextEffect];
    _nextEffect = (_nextEffect + 1) % _effects.length;
    player.stop().then((_) => player.play(BytesSource(bytes)));
  }

  // Motion sound

  void setMotion(KidsMotion motion) {
    if (motion == _motion) return;
    _motion = motion;
    if (_motionPlaying) {
      _motionPlaying = false;
      _motionPlayer?.stop();
    }
  }

  /// Call on every step; the sound fades by itself when steps stop.
  void pulseMotion() {
    final player = _motionPlayer;
    if (player == null) return;
    _motionVolume = 1;
    if (!_motionPlaying) {
      _motionPlaying = true;
      final bytes = _cache.putIfAbsent(
        'motion_${_motion.name}',
        () => _motion == KidsMotion.wind ? _wind() : _engine(),
      );
      player.play(BytesSource(bytes), volume: 0.9);
    } else {
      player.setVolume(0.9);
    }
    _decay ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      _motionVolume *= 0.8;
      if (_motionVolume < 0.05) {
        _motionVolume = 0;
        _motionPlaying = false;
        _motionPlayer?.stop();
        _decay?.cancel();
        _decay = null;
      } else {
        _motionPlayer?.setVolume(0.9 * _motionVolume);
      }
    });
  }

  void stopMotion() {
    _motionVolume = 0;
  }

  // Synthesis

  /// notes: [semitones above C5, start seconds, duration seconds]
  Uint8List _tones(List<List<double>> notes, [double amplitude = 0.3]) {
    var end = 0.0;
    for (final n in notes) {
      end = math.max(end, n[1] + n[2]);
    }
    final samples = List<double>.filled((end * _rate).ceil() + 1, 0);
    for (final n in notes) {
      final freq = 523.25 * math.pow(2, n[0] / 12);
      final start = (n[1] * _rate).round();
      final length = math.max(1, (n[2] * _rate).round());
      for (var t = 0; t < length && start + t < samples.length; t++) {
        final attack = math.min(1.0, t / (0.005 * _rate));
        final remaining = 1 - t / length;
        final phase = 2 * math.pi * freq * t / _rate;
        samples[start + t] +=
            amplitude * attack * remaining * remaining * (math.sin(phase) + 0.25 * math.sin(2 * phase));
      }
    }
    return _wav(samples.map((v) => v * 0.6).toList());
  }

  Uint8List _wind() {
    const seconds = 2.0, fade = 0.25;
    final loop = (seconds * _rate).round(), extra = (fade * _rate).round();
    final r = math.Random(7);
    final raw = List<double>.filled(loop + extra, 0);
    var low = 0.0, slow = 0.0;
    for (var i = 0; i < raw.length; i++) {
      low += ((r.nextDouble() * 2 - 1) - low) * 0.03;
      slow += ((r.nextDouble() * 2 - 1) - slow) * 0.0004;
      raw[i] = low * (1.3 + slow * 6);
    }
    // cross-fade the end into the start so the loop has no click
    final out = List<double>.generate(loop, (i) {
      if (i < extra) {
        final a = i / extra;
        return raw[i] * a + raw[loop + i] * (1 - a);
      }
      return raw[i];
    });
    return _wav(out.map((v) => v * 0.6).toList());
  }

  Uint8List _engine() {
    const seconds = 2.0; // 9 chugs and 124 rumble cycles: loops cleanly
    final n = (seconds * _rate).round();
    final r = math.Random(11);
    var low = 0.0;
    final out = List<double>.generate(n, (i) {
      final t = i / _rate;
      low += ((r.nextDouble() * 2 - 1) - low) * 0.2;
      final chug = math.pow(math.max(0.0, math.sin(2 * math.pi * 4.5 * t)), 6).toDouble();
      return (low * chug * 0.9 + math.sin(2 * math.pi * 62 * t) * 0.25) * 0.6;
    });
    return _wav(out);
  }

  Uint8List _wav(List<double> samples) {
    final data = ByteData(44 + samples.length * 2);
    void text(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    data.setUint32(4, 36 + samples.length * 2, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little); // PCM
    data.setUint16(22, 1, Endian.little); // mono
    data.setUint32(24, _rate, Endian.little);
    data.setUint32(28, _rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    text(36, 'data');
    data.setUint32(40, samples.length * 2, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      data.setInt16(44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }
}

// MARK: - Common page background

class KidsGameBackground extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const KidsGameBackground({super.key, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
      ),
      child: child,
    );
  }
}
