import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

const _basketEmoji = {
  'fruits': '🍎',
  'vegetables': '🥕',
  'animals': '🐘',
  'vehicles': '🚗',
  'farm': '🐄',
};

/// Sort It: pictures appear one at a time; drag each into the right basket.
/// 2 or 3 baskets by age.
class SortItScreen extends StatefulWidget {
  final KidsLanguage language;

  const SortItScreen({super.key, this.language = KidsLanguage.english});

  @override
  State<SortItScreen> createState() => _SortItScreenState();
}

class _SortItScreenState extends State<SortItScreen> {
  final _random = math.Random();
  bool _loading = true;
  int _level = 3;
  int _round = 0;
  List<String> _categories = [];
  List<String> _queue = [];
  final Map<String, List<String>> _sorted = {};
  bool _dragging = false;
  Offset _dragOffset = Offset.zero;
  int _shake = 0;
  final List<KidsBurst> _bursts = [];

  KidsLanguage get _lang => widget.language;

  String? get _current => _queue.isEmpty ? null : _queue.first;

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
      _newRound();
    });
  }

  @override
  void dispose() {
    KidsGameSound.instance.stop();
    KidsGameServices.stopSpeaking();
    super.dispose();
  }

  String _categoryOf(String subject) => KidsGamePictures.bySubject[subject]?.category ?? '';

  /// Animals and farm overlap (cow, chicken), so they never appear together.
  bool _clash(String a, String b) => {a, b}.containsAll(const ['animals', 'farm']);

  void _newRound() {
    _round++;
    final basketCount = _level >= 5 ? 3 : 2;
    final perBasket = _level <= 3 ? 3 : (_level == 4 ? 4 : 3);

    final byCategory = <String, List<String>>{};
    for (final s in KidsGamePictures.bySubject.keys) {
      byCategory.putIfAbsent(_categoryOf(s), () => []).add(s);
    }

    final chosen = <String>[];
    for (final c in byCategory.keys.toList()..shuffle(_random)) {
      if (chosen.length >= basketCount) break;
      if (chosen.any((x) => _clash(x, c))) continue;
      if ((byCategory[c]?.length ?? 0) >= perBasket) chosen.add(c);
    }

    final items = <String>[];
    for (final c in chosen) {
      items.addAll((List.of(byCategory[c]!)..shuffle(_random)).take(perBasket));
    }

    _categories = chosen;
    _queue = items..shuffle(_random);
    _sorted.clear();
    _dragging = false;
    _dragOffset = Offset.zero;
    _bursts.clear();
  }

  void _setLevel(int level) {
    if (level == _level) return;
    KidsAge.set(level);
    setState(() {
      _level = level;
      _newRound();
    });
  }

  // MARK: - Dropping

  void _drop(int? basket, Offset point, Size size) {
    final subject = _current;
    if (subject == null) return;

    if (basket != null && _categories[basket] == _categoryOf(subject)) {
      setState(() {
        _sorted.putIfAbsent(_categories[basket], () => []).add(subject);
        _queue.removeAt(0);
        _dragging = false;
        _dragOffset = Offset.zero;
      });
      KidsGameSound.instance.chime();
      HapticFeedback.mediumImpact();
      _addBurst(point, 14, 90);
      _lang.speak(KidsGamePictures.title(subject, _lang.id));
      if (_queue.isEmpty) _finish(size);
    } else {
      if (basket != null) {
        KidsGameSound.instance.boop();
        HapticFeedback.lightImpact();
        _shake++;
      }
      setState(() {
        _dragging = false;
        _dragOffset = Offset.zero;
      });
    }
  }

  void _finish(Size size) {
    final round = _round;
    KidsGameSound.instance.jingle();
    HapticFeedback.heavyImpact();
    for (var i = 0; i < 5; i++) {
      _addBurst(
        Offset((0.15 + _random.nextDouble() * 0.7) * size.width, (0.1 + _random.nextDouble() * 0.5) * size.height),
        22,
        160,
      );
    }
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted || round != _round) return;
      _lang.speak(CbnStrings.praiseFor(_lang.id));
    });
    Timer(const Duration(milliseconds: 3400), () {
      if (!mounted || round != _round) return;
      setState(_newRound);
    });
  }

  void _addBurst(Offset center, int count, double distance) {
    final burst = KidsBurst(
      center: center,
      colors: const [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink],
      count: count,
      distance: distance,
    );
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(_newRound)),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFF0FCF0), Color(0xFFFFF7EB)],
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
    final count = math.max(_categories.length, 1);
    const gap = 12.0;
    final basketW = (size.width - gap * (count - 1)) / count;
    final basketH = math.min(190.0, size.height * 0.32);
    final basketTop = size.height - basketH;
    final itemSize = math.min(size.width * 0.5, (basketTop - 40) * 0.8);
    final itemCenter = Offset(size.width / 2, basketTop / 2);

    Offset basketCenter(int i) => Offset((basketW + gap) * i + basketW / 2, basketTop + basketH / 2);

    final subject = _current;
    final page = subject == null ? null : KidsGamePictures.bySubject[subject];
    final itemPos = itemCenter + _dragOffset;
    final shown = _dragging ? itemSize * 0.8 : itemSize;

    return Stack(
      children: [
        for (var i = 0; i < _categories.length; i++)
          Positioned(
            left: (basketW + gap) * i,
            top: basketTop,
            width: basketW,
            height: basketH,
            child: _basket(_categories[i], basketW),
          ),
        // dotted guide ring
        Positioned(
          left: itemCenter.dx - itemSize * 0.55,
          top: itemCenter.dy - itemSize * 0.55,
          width: itemSize * 1.1,
          height: itemSize * 1.1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 3),
            ),
          ),
        ),
        // the picture to sort
        if (page != null)
          AnimatedPositioned(
            key: ValueKey('item-$_round-${_queue.length}'),
            duration: _dragging ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: itemPos.dx - shown / 2,
            top: itemPos.dy - shown / 2,
            width: shown,
            height: shown,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() => _dragging = true);
                KidsGameSound.instance.pop();
              },
              onPanUpdate: (d) => setState(() => _dragOffset += d.delta),
              onPanEnd: (_) {
                final at = itemCenter + _dragOffset;
                int? target;
                if (at.dy > basketTop - 40) {
                  final i = (at.dx / (basketW + gap)).floor();
                  if (i >= 0 && i < _categories.length) target = i;
                }
                _drop(target, target == null ? at : basketCenter(target), size);
              },
              child: KidsShake(
                trigger: _shake,
                child: Container(
                  padding: EdgeInsets.all(shown * 0.1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_dragging ? 0.25 : 0.1),
                        blurRadius: _dragging ? 12 : 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: KidsGamePicture(page: page),
                ),
              ),
            ),
          ),
        Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
      ],
    );
  }

  Widget _basket(String category, double width) {
    final sorted = _sorted[category] ?? const <String>[];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDBB37A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF9E7340), width: 4),
      ),
      child: Column(
        children: [
          Text(_basketEmoji[category] ?? '🧺', style: TextStyle(fontSize: math.min(44.0, width * 0.35))),
          const SizedBox(height: 6),
          // what has gone in so far
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final s in sorted)
                if (KidsGamePictures.bySubject[s] != null)
                  SizedBox(width: 30, height: 30, child: KidsGamePicture(page: KidsGamePictures.bySubject[s]!)),
            ],
          ),
        ],
      ),
    );
  }
}
