import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

/// Drag each picture onto its shadow.
class ShadowMatchScreen extends StatefulWidget {
  final KidsLanguage language;

  const ShadowMatchScreen({super.key, this.language = KidsLanguage.english});

  @override
  State<ShadowMatchScreen> createState() => _ShadowMatchScreenState();
}

class _ShadowMatchScreenState extends State<ShadowMatchScreen> {
  /// Shapes that look alike, used to make age 5 rounds harder.
  static const _lookAlikes = [
    ['apple', 'tomato', 'pumpkin', 'strawberry'],
    ['car', 'train', 'tractor'],
    ['fish', 'turtle', 'elephant'],
    ['corn', 'carrot', 'banana'],
  ];

  final _random = math.Random();
  final _boardKey = GlobalKey();
  final Map<String, GlobalKey> _shadowKeys = {};

  bool _loading = true;
  int _level = 3;
  int _round = 0;
  List<String> _pictures = [];
  List<String> _shadows = [];
  final Set<String> _matched = {};
  final Map<String, int> _wobble = {};
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
      _newRound();
    });
  }

  @override
  void dispose() {
    KidsGameSound.instance.stop();
    KidsGameServices.stopSpeaking();
    super.dispose();
  }

  // MARK: - Rounds

  void _newRound() {
    _round++;
    final all = KidsGamePictures.bySubject.keys.toList();
    final count = _level <= 3 ? 3 : (_level == 4 ? 4 : 6);
    final chosen = <String>[];

    if (_level <= 3) {
      // one per category, so the shapes are very different
      final byCategory = <String, List<String>>{};
      for (final s in all) {
        byCategory.putIfAbsent(KidsGamePictures.bySubject[s]?.category ?? '', () => []).add(s);
      }
      final categories = byCategory.keys.toList()..shuffle(_random);
      for (final c in categories.take(count)) {
        final list = byCategory[c]!;
        chosen.add(list[_random.nextInt(list.length)]);
      }
    } else if (_level >= 5) {
      final group = _lookAlikes[_random.nextInt(_lookAlikes.length)].where(all.contains).toList()
        ..shuffle(_random);
      chosen.addAll(group.take(3));
    }
    for (final s in (List.of(all)..shuffle(_random))) {
      if (chosen.length >= count) break;
      if (!chosen.contains(s)) chosen.add(s);
    }

    final left = List.of(chosen)..shuffle(_random);
    final right = List.of(chosen)..shuffle(_random);
    if (right.length > 1 && _sameOrder(left, right)) {
      final first = right[0];
      right[0] = right[1];
      right[1] = first;
    }

    _pictures = left;
    _shadows = right;
    _matched.clear();
    _wobble.clear();
    _bursts.clear();
  }

  bool _sameOrder(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _setLevel(int level) {
    if (level == _level) return;
    KidsAge.set(level);
    setState(() {
      _level = level;
      _newRound();
    });
  }

  // MARK: - Matching

  void _drop(String dragged, String target) {
    if (_matched.contains(target)) return;

    if (dragged == target) {
      setState(() => _matched.add(target));
      KidsGameSound.instance.chime();
      HapticFeedback.mediumImpact();
      final center = _centerOf(_shadowKeys[target]);
      if (center != null) {
        _addBurst(KidsBurst(center: center, colors: KidsGamePictures.colors(target), count: 18, distance: 110));
      }
      _lang.speak(KidsGamePictures.title(target, _lang.id));
      if (_matched.length == _pictures.length) _finishRound();
    } else {
      KidsGameSound.instance.boop();
      HapticFeedback.lightImpact();
      setState(() => _wobble[dragged] = (_wobble[dragged] ?? 0) + 1);
    }
  }

  Offset? _centerOf(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || board == null) return null;
    return board.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
  }

  void _finishRound() {
    final round = _round;
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted || round != _round) return;
      KidsGameSound.instance.jingle();
      HapticFeedback.heavyImpact();
      final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
      final size = board?.size ?? const Size(360, 600);
      const colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink];
      for (var i = 0; i < 6; i++) {
        _addBurst(KidsBurst(
          center: Offset(
            (0.15 + _random.nextDouble() * 0.7) * size.width,
            (0.15 + _random.nextDouble() * 0.7) * size.height,
          ),
          colors: colors,
          count: 22,
          distance: 170,
        ));
      }
      _lang.speak(CbnStrings.praiseFor(_lang.id));
    });
    // a new round starts by itself
    Timer(const Duration(milliseconds: 3600), () {
      if (!mounted || round != _round) return;
      setState(_newRound);
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(_newRound)),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFFFF8FC), Color(0xFFF0F7FF)],
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: LayoutBuilder(builder: (context, c) => _board(Size(c.maxWidth, c.maxHeight))),
                ),
        ),
      ),
    );
  }

  Widget _board(Size size) {
    final count = math.max(_pictures.length, 1);
    const gap = 12.0;
    final tile = math.max(44.0, math.min((size.height - gap * (count - 1)) / count, size.width * 0.38));

    return Stack(
      key: _boardKey,
      children: [
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _pictures.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i < _pictures.length - 1 ? gap : 0),
                  child: Row(
                    children: [
                      Expanded(child: Center(child: _pictureTile(_pictures[i], tile))),
                      Expanded(child: Center(child: _shadowTile(_shadows[i], tile))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
      ],
    );
  }

  Widget _card(String subject, double tile, {bool lifted = false}) {
    final page = KidsGamePictures.bySubject[subject];
    return Container(
      width: tile,
      height: tile,
      padding: EdgeInsets.all(tile * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(lifted ? 0.22 : 0.08),
            blurRadius: lifted ? 12 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: page == null ? null : KidsGamePicture(page: page),
    );
  }

  Widget _pictureTile(String subject, double tile) {
    final card = _card(subject, tile);
    if (_matched.contains(subject)) {
      return Opacity(opacity: 0.25, child: card);
    }
    return KidsShake(
      trigger: _wobble[subject] ?? 0,
      child: Draggable<String>(
        data: subject,
        onDragStarted: KidsGameSound.instance.pop,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(scale: 1.12, child: _card(subject, tile, lifted: true)),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: card),
        child: card,
      ),
    );
  }

  Widget _shadowTile(String subject, double tile) {
    final key = _shadowKeys.putIfAbsent(subject, () => GlobalKey());
    final matched = _matched.contains(subject);
    final page = KidsGamePictures.bySubject[subject];

    return DragTarget<String>(
      key: key,
      onAcceptWithDetails: (details) => _drop(details.data, subject),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty && !matched;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: tile,
          height: tile,
          padding: EdgeInsets.all(tile * 0.1),
          decoration: BoxDecoration(
            color: matched
                ? Colors.yellow.withOpacity(0.25)
                : (hovering ? Colors.blue.withOpacity(0.10) : Colors.white.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: matched ? Colors.green : Colors.grey.withOpacity(0.35),
              width: matched ? 3 : 2,
            ),
          ),
          child: page == null
              ? null
              : AnimatedScale(
                  scale: matched ? 1.08 : 1,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.elasticOut,
                  child: KidsGamePicture(page: page, shadow: !matched),
                ),
        );
      },
    );
  }
}
