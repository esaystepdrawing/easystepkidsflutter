import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cbn_models.dart';
import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

/// Jigsaw: a picture cut into pieces. Drag each piece from the tray onto the
/// board; it snaps when close. 4 / 6 / 9 pieces by age.
class JigsawScreen extends StatefulWidget {
  final KidsLanguage language;

  const JigsawScreen({super.key, this.language = KidsLanguage.english});

  @override
  State<JigsawScreen> createState() => _JigsawScreenState();
}

class _JigsawScreenState extends State<JigsawScreen> {
  final _random = math.Random();
  bool _loading = true;
  int _level = 3;
  int _round = 0;
  String _subject = 'apple';
  int _rows = 2;
  int _cols = 2;
  List<int> _traySlot = [];
  final Set<int> _placed = {};
  int? _dragging;
  Offset _dragOffset = Offset.zero;
  final List<KidsBurst> _bursts = [];
  Size _boardSize = const Size(360, 640);

  KidsLanguage get _lang => widget.language;

  int get _pieceCount => _rows * _cols;

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

  void _newGame() {
    _round++;
    if (_level <= 3) {
      _cols = 2;
      _rows = 2;
    } else if (_level == 4) {
      _cols = 3;
      _rows = 2;
    } else {
      _cols = 3;
      _rows = 3;
    }
    final options = KidsGamePictures.bySubject.keys.where((s) => s != _subject).toList();
    if (options.isNotEmpty) _subject = options[_random.nextInt(options.length)];
    _traySlot = List.generate(_pieceCount, (i) => i)..shuffle(_random);
    _placed.clear();
    _dragging = null;
    _dragOffset = Offset.zero;
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

  // MARK: - Layout

  _JigsawLayout _layout(Size size) {
    final side = math.min(size.width, size.height * 0.52);
    final pieceW = side / _cols;
    final pieceH = side / _rows;
    final trayTop = side + 20;
    final trayHeight = size.height - trayTop;
    final fitW = (size.width - 8 * (_cols + 1)) / (_cols * pieceW);
    final fitH = (trayHeight - 8 * (_rows + 1)) / (_rows * pieceH);
    final scale = math.max(0.4, math.min(0.85, math.min(fitW, fitH)));
    return _JigsawLayout(
      boardOrigin: Offset((size.width - side) / 2, 0),
      side: side,
      pieceW: pieceW,
      pieceH: pieceH,
      trayTop: trayTop,
      trayScale: scale,
      size: size,
    );
  }

  Offset _trayCenter(int slot, _JigsawLayout l) {
    final w = l.pieceW * l.trayScale + 8;
    final h = l.pieceH * l.trayScale + 8;
    final startX = (l.size.width - w * _cols) / 2;
    final trayHeight = l.size.height - l.trayTop;
    final startY = l.trayTop + math.max(0.0, (trayHeight - h * _rows) / 2);
    return Offset(startX + (slot % _cols + 0.5) * w, startY + (slot ~/ _cols + 0.5) * h);
  }

  // MARK: - Moves

  void _dragStart(int piece) {
    if (_placed.contains(piece)) return;
    setState(() {
      _dragging = piece;
      _dragOffset = Offset.zero;
    });
    KidsGameSound.instance.pop();
  }

  void _dragUpdate(int piece, Offset delta) {
    if (_dragging != piece) return;
    setState(() => _dragOffset += delta);
  }

  void _dragEnd(int piece, _JigsawLayout l) {
    if (_dragging != piece) return;
    final row = piece ~/ _cols, col = piece % _cols;
    final target = l.target(row, col);
    final dropped = _trayCenter(_traySlot[piece], l) + _dragOffset;
    final close = (dropped - target).distance < math.min(l.pieceW, l.pieceH) * 0.45;

    setState(() {
      if (close) _placed.add(piece);
      _dragging = null;
      _dragOffset = Offset.zero;
    });
    if (close) {
      KidsGameSound.instance.chime();
      HapticFeedback.mediumImpact();
      _addBurst(target, 12, 80);
      if (_placed.length == _pieceCount) _finish();
    } else {
      KidsGameSound.instance.boop();
    }
  }

  void _finish() {
    final round = _round;
    KidsGameSound.instance.jingle();
    HapticFeedback.heavyImpact();
    for (var i = 0; i < 5; i++) {
      _addBurst(
        Offset((0.15 + _random.nextDouble() * 0.7) * _boardSize.width,
            (0.1 + _random.nextDouble() * 0.5) * _boardSize.height),
        22,
        160,
      );
    }
    _lang.speak('${CbnStrings.praiseFor(_lang.id)} ${KidsGamePictures.title(_subject, _lang.id)}');
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted || round != _round) return;
      setState(_newGame);
    });
  }

  void _addBurst(Offset center, int count, double distance) {
    final burst = KidsBurst(center: center, colors: KidsGamePictures.colors(_subject), count: count, distance: distance);
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(_newGame)),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFF2F7FF), Color(0xFFFFF7ED)],
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(builder: (context, c) {
                    _boardSize = Size(c.maxWidth, c.maxHeight);
                    return _board(_boardSize);
                  }),
                ),
        ),
      ),
    );
  }

  Widget _board(Size size) {
    final l = _layout(size);
    final page = KidsGamePictures.bySubject[_subject];

    // dragged piece last so it is drawn on top
    final order = List.generate(_pieceCount, (i) => i)
      ..sort((a, b) {
        int rank(int p) => p == _dragging ? 2 : (_placed.contains(p) ? 0 : 1);
        return rank(a).compareTo(rank(b));
      });

    return Stack(
      children: [
        // board with a faint guide picture
        Positioned(
          left: l.boardOrigin.dx,
          top: l.boardOrigin.dy,
          width: l.side,
          height: l.side,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Stack(children: [
              if (page != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: _level >= 5 ? 0.07 : 0.16,
                    child: KidsGamePicture(page: page, shadow: true),
                  ),
                ),
              Positioned.fill(child: CustomPaint(painter: _GridPainter(_rows, _cols))),
            ]),
          ),
        ),
        if (page != null)
          for (final piece in order) _piece(piece, page, l),
        Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
      ],
    );
  }

  Widget _piece(int piece, CbnPage page, _JigsawLayout l) {
    final row = piece ~/ _cols, col = piece % _cols;
    final placed = _placed.contains(piece);
    final dragging = _dragging == piece;
    final center = placed ? l.target(row, col) : _trayCenter(_traySlot[piece], l) + (dragging ? _dragOffset : Offset.zero);
    final scale = (placed || dragging) ? 1.0 : l.trayScale;

    return AnimatedPositioned(
      key: ValueKey('piece-$_round-$piece'),
      duration: dragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      left: center.dx - l.pieceW / 2,
      top: center.dy - l.pieceH / 2,
      width: l.pieceW,
      height: l.pieceH,
      child: GestureDetector(
        onPanStart: placed ? null : (_) => _dragStart(piece),
        onPanUpdate: placed ? null : (d) => _dragUpdate(piece, d.delta),
        onPanEnd: placed ? null : (_) => _dragEnd(piece, l),
        child: Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black.withOpacity(placed ? 0.08 : 0.25), width: placed ? 0.5 : 2),
              boxShadow: placed
                  ? null
                  : [BoxShadow(color: Colors.black.withOpacity(dragging ? 0.3 : 0.15), blurRadius: dragging ? 10 : 4)],
            ),
            child: CustomPaint(painter: _PiecePainter(page, l.side, row, col, l.pieceW, l.pieceH)),
          ),
        ),
      ),
    );
  }
}

class _JigsawLayout {
  final Offset boardOrigin;
  final double side;
  final double pieceW;
  final double pieceH;
  final double trayTop;
  final double trayScale;
  final Size size;

  _JigsawLayout({
    required this.boardOrigin,
    required this.side,
    required this.pieceW,
    required this.pieceH,
    required this.trayTop,
    required this.trayScale,
    required this.size,
  });

  Offset target(int row, int col) =>
      Offset(boardOrigin.dx + (col + 0.5) * pieceW, boardOrigin.dy + (row + 0.5) * pieceH);
}

/// Draws one piece: the whole picture, shifted so only this piece's part shows.
class _PiecePainter extends CustomPainter {
  final CbnPage page;
  final double side;
  final int row;
  final int col;
  final double pieceW;
  final double pieceH;

  _PiecePainter(this.page, this.side, this.row, this.col, this.pieceW, this.pieceH);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / pieceW, size.height / pieceH);
    canvas.translate(-col * pieceW, -row * pieceH);
    final fit = CbnFit.of(page.contentBounds, Size(side, side));
    canvas.translate(fit.offset.dx, fit.offset.dy);
    canvas.scale(fit.scale);
    cbnPaintPage(canvas, page, allColored: true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.page != page || old.side != side || old.row != row || old.col != col;
}

class _GridPainter extends CustomPainter {
  final int rows;
  final int cols;

  _GridPainter(this.rows, this.cols);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1.5;
    for (var c = 1; c < cols; c++) {
      final x = size.width * c / cols;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var r = 1; r < rows; r++) {
      final y = size.height * r / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.rows != rows || old.cols != cols;
}
