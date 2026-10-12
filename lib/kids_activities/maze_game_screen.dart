import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

/// Drag the character through the maze to its goal.
/// A new maze is generated on every refresh and after every win.
class MazeGameScreen extends StatefulWidget {
  final KidsLanguage language;

  const MazeGameScreen({super.key, this.language = KidsLanguage.english});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

// MARK: - Maze model

class MazeCell {
  final int row;
  final int col;

  const MazeCell(this.row, this.col);

  @override
  bool operator ==(Object other) => other is MazeCell && other.row == row && other.col == col;

  @override
  int get hashCode => row * 1000 + col;
}

class MazeGrid {
  static const north = 1, east = 2, south = 4, west = 8;

  final int size;

  /// Open directions per cell, as a bitmask of north/east/south/west.
  final List<List<int>> _open;

  MazeGrid._(this.size, this._open);

  /// A random "perfect" maze: exactly one route between any two cells.
  factory MazeGrid.random(int size, math.Random random) {
    final open = List.generate(size, (_) => List.filled(size, 0));
    final visited = List.generate(size, (_) => List.filled(size, false));
    final stack = <MazeCell>[const MazeCell(0, 0)];
    visited[0][0] = true;

    while (stack.isNotEmpty) {
      final cur = stack.last;
      final r = cur.row, c = cur.col;
      final options = <List<int>>[]; // row, col, dir, back
      if (r > 0 && !visited[r - 1][c]) options.add([r - 1, c, north, south]);
      if (c < size - 1 && !visited[r][c + 1]) options.add([r, c + 1, east, west]);
      if (r < size - 1 && !visited[r + 1][c]) options.add([r + 1, c, south, north]);
      if (c > 0 && !visited[r][c - 1]) options.add([r, c - 1, west, east]);

      if (options.isEmpty) {
        stack.removeLast();
      } else {
        final pick = options[random.nextInt(options.length)];
        open[r][c] |= pick[2];
        open[pick[0]][pick[1]] |= pick[3];
        visited[pick[0]][pick[1]] = true;
        stack.add(MazeCell(pick[0], pick[1]));
      }
    }
    return MazeGrid._(size, open);
  }

  bool isOpen(MazeCell c, int direction) => _open[c.row][c.col] & direction != 0;

  List<MazeCell> neighbors(MazeCell c) => [
        if (isOpen(c, north)) MazeCell(c.row - 1, c.col),
        if (isOpen(c, east)) MazeCell(c.row, c.col + 1),
        if (isOpen(c, south)) MazeCell(c.row + 1, c.col),
        if (isOpen(c, west)) MazeCell(c.row, c.col - 1),
      ];

  /// The cell with the longest route from [start]; used as the goal.
  MazeCell farthest(MazeCell start) {
    final distance = <MazeCell, int>{start: 0};
    final queue = <MazeCell>[start];
    var best = start;
    for (var i = 0; i < queue.length; i++) {
      final cell = queue[i];
      for (final next in neighbors(cell)) {
        if (distance.containsKey(next)) continue;
        distance[next] = distance[cell]! + 1;
        queue.add(next);
        if (distance[next]! > distance[best]!) best = next;
      }
    }
    return best;
  }
}

class _MazeLayout {
  final Offset origin;
  final double cell;
  final int count;
  final Rect frame;
  final Size boardSize;

  _MazeLayout(this.origin, this.cell, this.count, this.frame, this.boardSize);

  factory _MazeLayout.of(Size size, int count) {
    final side = math.min(size.width, size.height);
    final frame = Rect.fromLTWH((size.width - side) / 2, (size.height - side) / 2, side, side);
    final pad = side * 0.04;
    return _MazeLayout(
      Offset(frame.left + pad, frame.top + pad),
      (side - pad * 2) / count,
      count,
      frame,
      size,
    );
  }

  Offset center(MazeCell c) => Offset(origin.dx + (c.col + 0.5) * cell, origin.dy + (c.row + 0.5) * cell);

  MazeCell cellAt(Offset p) => MazeCell(
        ((p.dy - origin.dy) / cell).floor().clamp(0, count - 1).toInt(),
        ((p.dx - origin.dx) / cell).floor().clamp(0, count - 1).toInt(),
      );
}

// MARK: - Screen

class _MazeGameScreenState extends State<MazeGameScreen> {
  /// Who walks, and where to.
  static const _pairs = [
    ['cow', 'barn'], ['chicken', 'corn'], ['elephant', 'banana'],
    ['tractor', 'pumpkin'], ['butterfly', 'strawberry'], ['turtle', 'tomato'],
    ['fish', 'boat'], ['car', 'barn'], ['train', 'barn'],
  ];
  static const _engines = {'car', 'train', 'tractor', 'boat', 'rocket'};

  final _random = math.Random();

  bool _loading = true;
  int _level = 3;
  int _round = 0;
  late MazeGrid _grid = MazeGrid.random(4, _random);
  MazeCell _player = const MazeCell(0, 0);
  MazeCell _goal = const MazeCell(0, 0);
  List<MazeCell> _trail = [];
  bool _finished = false;
  bool _dragOnPlayer = false;
  String _startSubject = 'cow';
  String _goalSubject = 'barn';
  final List<KidsBurst> _bursts = [];

  KidsLanguage get _lang => widget.language;

  static int _gridSize(int level) => level <= 3 ? 4 : (level == 4 ? 6 : 8);

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
      _newGame(speak: false);
    });
    _speakIntro();
  }

  @override
  void dispose() {
    KidsGameSound.instance.stop();
    KidsGameServices.stopSpeaking();
    super.dispose();
  }

  // MARK: - Games

  void _newGame({bool speak = true}) {
    _round++;
    _grid = MazeGrid.random(_gridSize(_level), _random);
    _player = const MazeCell(0, 0);
    _goal = _grid.farthest(_player);
    _trail = [_player];
    _finished = false;
    _dragOnPlayer = false;
    _bursts.clear();

    final available = _pairs
        .where((p) => KidsGamePictures.bySubject.containsKey(p[0]) && KidsGamePictures.bySubject.containsKey(p[1]))
        .toList();
    if (available.isNotEmpty) {
      final pair = available[_random.nextInt(available.length)];
      _startSubject = pair[0];
      _goalSubject = pair[1];
    }
    KidsGameSound.instance.stopMotion();
    KidsGameSound.instance.setMotion(_engines.contains(_startSubject) ? KidsMotion.engine : KidsMotion.wind);
    if (speak) _speakIntro();
  }

  void _speakIntro() {
    final start = KidsGamePictures.title(_startSubject, _lang.id);
    final end = KidsGamePictures.title(_goalSubject, _lang.id);
    _lang.speak('$start … $end');
  }

  void _setLevel(int level) {
    if (level == _level) return;
    KidsAge.set(level);
    setState(() {
      _level = level;
      _newGame();
    });
  }

  // MARK: - Moving

  /// Moves the character toward the cell under the finger, one cell at a
  /// time, only through open paths.
  void _dragTo(MazeCell target, _MazeLayout layout) {
    if (_finished) return;
    var steps = 0;
    while (_player != target && steps < _grid.size * 2 && !_finished) {
      final next = _nextStep(target);
      if (next == null) break;
      _move(next, layout);
      steps++;
    }
  }

  MazeCell? _nextStep(MazeCell target) {
    final options = _grid.neighbors(_player);
    if (options.contains(target)) return target;
    // the finger is further along a straight path: take one step that way
    if (target.row == _player.row || target.col == _player.col) {
      final next = MazeCell(
        _player.row + (target.row - _player.row).sign,
        _player.col + (target.col - _player.col).sign,
      );
      if (options.contains(next)) return next;
    }
    return null;
  }

  void _move(MazeCell cell, _MazeLayout layout) {
    setState(() {
      _player = cell;
      final index = _trail.indexOf(cell);
      if (index >= 0) {
        _trail = _trail.sublist(0, index + 1); // walking back erases the trail
      } else {
        _trail = [..._trail, cell];
      }
    });
    KidsGameSound.instance.pulseMotion();
    HapticFeedback.selectionClick();

    if (cell == _goal) {
      setState(() {
        _finished = true;
        _dragOnPlayer = false;
      });
      _celebrate(layout);
    }
  }

  // MARK: - Winning

  void _celebrate(_MazeLayout layout) {
    final round = _round;
    KidsGameSound.instance.stopMotion();
    KidsGameSound.instance.jingle();
    HapticFeedback.heavyImpact();

    final colors = [...KidsGamePictures.colors(_startSubject), ...KidsGamePictures.colors(_goalSubject)];
    _addBurst(KidsBurst(center: layout.center(_goal), colors: colors, count: 30, distance: 190));
    const party = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink];
    for (var i = 0; i < 4; i++) {
      _addBurst(KidsBurst(
        center: Offset(
          (0.15 + _random.nextDouble() * 0.7) * layout.boardSize.width,
          (0.15 + _random.nextDouble() * 0.7) * layout.boardSize.height,
        ),
        colors: party,
        count: 20,
        distance: 150,
      ));
    }

    final end = KidsGamePictures.title(_goalSubject, _lang.id);
    _lang.speak('${CbnStrings.praiseFor(_lang.id)} $end');

    // a new maze starts by itself
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted || round != _round) return;
      setState(() => _newGame());
    });
  }

  void _addBurst(KidsBurst burst) {
    setState(() => _bursts.add(burst));
    Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _bursts.removeWhere((b) => b.id == burst.id));
    });
  }

  // MARK: - UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          KidsAgeMenu(level: _level, onSelect: _setLevel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _newGame())),
          IconButton(icon: const Icon(Icons.volume_up), onPressed: _speakIntro),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFF0FCEE), Color(0xFFFFFAEB)],
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
    final layout = _MazeLayout.of(size, _grid.size);
    final pictureSize = layout.cell * 0.86;
    final goalPage = KidsGamePictures.bySubject[_goalSubject];
    final playerPage = KidsGamePictures.bySubject[_startSubject];

    Rect box(MazeCell c, double s) => Rect.fromCenter(center: layout.center(c), width: s, height: s);

    final goalBox = box(_goal, pictureSize);
    final playerSize = _dragOnPlayer ? pictureSize * 1.15 : pictureSize;
    final playerBox = box(_player, playerSize);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) {
        final near = (d.localPosition - layout.center(_player)).distance < layout.cell * 0.9;
        setState(() => _dragOnPlayer = near && !_finished);
      },
      onPanUpdate: (d) {
        if (_dragOnPlayer) _dragTo(layout.cellAt(d.localPosition), layout);
      },
      onPanEnd: (_) => setState(() => _dragOnPlayer = false),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MazePainter(_grid, layout, _goal, List.of(_trail))),
          ),
          if (goalPage != null)
            Positioned.fromRect(
              rect: goalBox,
              child: _finished ? KidsScatterView(page: goalPage) : KidsGamePicture(page: goalPage),
            ),
          if (playerPage != null)
            AnimatedPositioned.fromRect(
              rect: playerBox,
              duration: const Duration(milliseconds: 90),
              child: _finished ? KidsScatterView(page: playerPage) : KidsGamePicture(page: playerPage),
            ),
          Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
        ],
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final MazeGrid grid;
  final _MazeLayout layout;
  final MazeCell goal;
  final List<MazeCell> trail;

  _MazePainter(this.grid, this.layout, this.goal, this.trail);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = layout.cell;
    final width = cell * 0.68;

    // grass
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.frame, const Radius.circular(24)),
      Paint()..color = const Color(0xFF8CCC66),
    );

    // paths: a brown edge first, then the cream path on top
    for (final pass in [
      [const Color(0xFF8C6B3D), 6.0],
      [const Color(0xFFFFF7E0), 0.0],
    ]) {
      final paint = Paint()..color = pass[0] as Color;
      final w = width + (pass[1] as double);
      for (var row = 0; row < grid.size; row++) {
        for (var col = 0; col < grid.size; col++) {
          final c = MazeCell(row, col);
          final p = layout.center(c);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: p, width: w, height: w), Radius.circular(w * 0.2)),
            paint,
          );
          if (grid.isOpen(c, MazeGrid.east)) {
            canvas.drawRect(Rect.fromLTWH(p.dx, p.dy - w / 2, cell, w), paint);
          }
          if (grid.isOpen(c, MazeGrid.south)) {
            canvas.drawRect(Rect.fromLTWH(p.dx - w / 2, p.dy, w, cell), paint);
          }
        }
      }
    }

    // glow under the goal
    canvas.drawCircle(layout.center(goal), cell * 0.42, Paint()..color = Colors.yellow.withOpacity(0.45));

    // dotted trail where the child has been
    final dot = Paint()..color = const Color(0xFFFA8C1A);
    final step = cell * 0.25;
    for (var i = 1; i < trail.length; i++) {
      final a = layout.center(trail[i - 1]);
      final b = layout.center(trail[i]);
      final length = (b - a).distance;
      for (var d = 0.0; d < length; d += step) {
        canvas.drawCircle(a + (b - a) * (d / length), cell * 0.06, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_MazePainter old) => true;
}
