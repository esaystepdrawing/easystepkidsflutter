import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cbn_models.dart';
import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

/// Color by Number. Numbers and color names are shown and spoken in [language].
class ColorByNumberScreen extends StatefulWidget {
  final KidsLanguage language;

  const ColorByNumberScreen({super.key, this.language = KidsLanguage.english});

  @override
  State<ColorByNumberScreen> createState() => _ColorByNumberScreenState();
}

class _ColorByNumberScreenState extends State<ColorByNumberScreen> {
  static const _categoryOrder = ['fruits', 'vegetables', 'animals', 'vehicles', 'farm'];
  static const _emoji = {
    'fruits': '🍎',
    'vegetables': '🥕',
    'animals': '🐘',
    'vehicles': '🚗',
    'farm': '🐄',
  };

  bool _loading = true;
  List<CbnPage> _library = [];
  List<CbnPage> _pages = [];
  int _level = 3;
  String _category = '';
  int _pageIndex = 0;
  int _selected = 1;
  int? _hint;
  int _shake = 0;

  /// page id -> ids of regions already colored (kept while the screen is open)
  final Map<String, Set<String>> _filled = {};
  final List<KidsBurst> _bursts = [];
  Timer? _hintTimer;

  KidsLanguage get _lang => widget.language;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final level = await KidsAge.load();
    final library = await CbnLibrary.loadAll();
    if (!mounted) return;
    setState(() {
      _library = library;
      _level = level;
      _loading = false;
      _loadPages();
    });
    _speakTitle();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    KidsGameServices.stopSpeaking();
    super.dispose();
  }

  // MARK: - Pages

  List<String> get _categories {
    final present = _pages.map((p) => p.category).toSet();
    final ordered = _categoryOrder.where(present.contains).toList();
    final rest = present.difference(_categoryOrder.toSet()).toList()..sort();
    return [...ordered, ...rest];
  }

  List<CbnPage> get _inCategory => _pages.where((p) => p.category == _category).toList();

  CbnPage? get _page {
    final list = _inCategory;
    return _pageIndex < list.length ? list[_pageIndex] : null;
  }

  Set<String> _filledFor(CbnPage p) => _filled[p.id] ?? <String>{};

  bool _isDone(CbnPage p) => _filledFor(p).length >= p.regions.length;

  int _remaining(int number, CbnPage p) {
    final done = _filledFor(p);
    return p.regions.where((r) => r.number == number && !done.contains(r.id)).length;
  }

  String _title(CbnPage p) => CbnStrings.title(p.subject, _lang.id) ?? p.title;

  void _loadPages() {
    _pages = CbnLibrary.pagesForLevel(_level, _library);
    final cats = _categories;
    if (!cats.contains(_category)) {
      _category = cats.isNotEmpty ? cats.first : '';
      _pageIndex = 0;
    }
    if (_pageIndex >= _inCategory.length) _pageIndex = 0;
    final p = _page;
    if (p != null) _selectFirstUnfinished(p);
  }

  void _selectFirstUnfinished(CbnPage p) {
    for (final c in p.palette) {
      if (_remaining(c.number, p) > 0) {
        _selected = c.number;
        return;
      }
    }
    _selected = p.palette.isNotEmpty ? p.palette.first.number : 1;
  }

  void _speakTitle() {
    final p = _page;
    if (p != null) _lang.speak(_title(p));
  }

  void _pageChanged() {
    _bursts.clear();
    _hint = null;
    final p = _page;
    if (p != null) _selectFirstUnfinished(p);
    _speakTitle();
  }

  void _selectCategory(String category) {
    if (category == _category) return;
    setState(() {
      _category = category;
      _pageIndex = 0;
      _pageChanged();
    });
  }

  void _next() {
    if (_pageIndex >= _inCategory.length - 1) return;
    setState(() {
      _pageIndex++;
      _pageChanged();
    });
  }

  void _prev() {
    if (_pageIndex <= 0) return;
    setState(() {
      _pageIndex--;
      _pageChanged();
    });
  }

  void _reset() {
    final p = _page;
    if (p == null) return;
    setState(() {
      _filled[p.id] = <String>{};
      _bursts.clear();
      _selectFirstUnfinished(p);
    });
  }

  void _setLevel(int level) {
    if (level == _level) return;
    KidsAge.set(level);
    setState(() {
      _level = level;
      _bursts.clear();
      _loadPages();
    });
  }

  // MARK: - Coloring

  void _select(int number, CbnPage page) {
    setState(() => _selected = number);
    _lang.speak('${_lang.numberWord(number)}, ${_lang.colorWord(page.colorNameFor(number))}');
  }

  /// How far outside a region a tap still counts. Younger children get more room.
  double get _tolerance => _level <= 3 ? 26 : (_level == 4 ? 16 : 10);

  void _handleTap(Offset local, Size size, CbnPage page) {
    if (_isDone(page)) return;
    final fit = CbnFit.of(page.viewBox, size);
    final done = _filledFor(page);

    // later regions are drawn on top, so search from the end
    CbnRegion? topAt(Offset screen) {
      final pt = fit.toPage(screen);
      for (final r in page.regions.reversed) {
        if (r.path.contains(pt)) return r;
      }
      return null;
    }

    CbnRegion? matching(CbnRegion? r) =>
        (r != null && !done.contains(r.id) && r.number == _selected) ? r : null;

    final direct = topAt(local);
    var target = matching(direct);

    // near miss: look in a small ring around the finger
    if (target == null) {
      outer:
      for (final radius in [_tolerance * 0.5, _tolerance]) {
        for (var k = 0; k < 8; k++) {
          final a = k * math.pi / 4;
          final found = matching(topAt(local + Offset(math.cos(a), math.sin(a)) * radius));
          if (found != null) {
            target = found;
            break outer;
          }
        }
      }
    }

    if (target != null) {
      _fill(target, page, size);
    } else if (direct != null && !done.contains(direct.id)) {
      _wrongTap(direct);
    }
  }

  void _fill(CbnRegion region, CbnPage page, Size size) {
    setState(() {
      _filled.putIfAbsent(page.id, () => <String>{}).add(region.id);
    });
    HapticFeedback.mediumImpact();

    if (_isDone(page)) {
      _celebrate(page, size);
      _lang.speak('${CbnStrings.praiseFor(_lang.id)} ${_title(page)}');
      return;
    }

    _lang.speak(_lang.colorWord(page.colorNameFor(region.number)));
    // when a color is used up, move on to the next one still needed
    if (_remaining(_selected, page) == 0) {
      setState(() => _selectFirstUnfinished(page));
    }
  }

  void _wrongTap(CbnRegion region) {
    HapticFeedback.lightImpact();
    setState(() {
      _shake++;
      _hint = region.number;
    });
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  void _celebrate(CbnPage page, Size size) {
    final colors = [...page.palette.map((p) => p.color), Colors.yellow, Colors.pink];
    final center = size.center(Offset.zero);
    _addBurst(KidsBurst(center: center, colors: colors, count: 40, distance: size.shortestSide * 0.5));
    _addBurst(KidsBurst(center: center + Offset(-size.width * 0.25, -size.height * 0.2), colors: colors, count: 18));
    _addBurst(KidsBurst(center: center + Offset(size.width * 0.25, -size.height * 0.15), colors: colors, count: 18));
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
    final page = _page;
    return Scaffold(
      appBar: AppBar(
        title: Text(page == null ? '' : _title(page)),
        centerTitle: true,
        actions: [
          KidsAgeMenu(level: _level, onSelect: _setLevel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
          IconButton(icon: const Icon(Icons.volume_up), onPressed: _speakTitle),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFFFFEF8), Color(0xFFF0FDF5)],
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : page == null
                  ? const Center(
                      child: Text(
                        'No coloring pages found.\nAdd assets/coloring_pages/ to pubspec.yaml.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: [
                        _categoryBar(),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: AspectRatio(aspectRatio: 1, child: _canvas(page)),
                              ),
                            ),
                          ),
                        ),
                        _palette(page),
                        _bottomBar(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _categoryBar() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final c in _categories)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => _selectCategory(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c == _category ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: c == _category ? Colors.orange : Colors.grey.withOpacity(0.3),
                      width: c == _category ? 2 : 1,
                    ),
                  ),
                  child: Text(_emoji[c] ?? '🎨', style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _canvas(CbnPage page) {
    final done = _isDone(page);
    return KidsShake(
      trigger: _shake,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: done ? Colors.green : Colors.orange.withOpacity(0.35),
            width: done ? 3 : 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (d) => _handleTap(d.localPosition, size, page),
                      child: CustomPaint(
                        painter: _ColoringPainter(page, Set.of(_filledFor(page)), _lang),
                      ),
                    ),
                  ),
                  Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _palette(CbnPage page) {
    final count = page.palette.length;
    // pages for older children have 5 or 6 colors, so the buttons shrink to fit
    final chip = count <= 4 ? 58.0 : (count == 5 ? 50.0 : 44.0);
    final gap = count <= 4 ? 18.0 : (count == 5 ? 14.0 : 10.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in page.palette)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: _chip(entry, page, chip, gap),
            ),
        ],
      ),
    );
  }

  Widget _chip(CbnPaletteColor entry, CbnPage page, double chip, double gap) {
    final selected = entry.number == _selected;
    final hinted = entry.number == _hint;
    final done = _remaining(entry.number, page) == 0;

    return GestureDetector(
      onTap: done ? null : () => _select(entry.number, page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: hinted ? 1.3 : (selected ? 1.12 : 1.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Opacity(
              opacity: done ? 0.45 : 1,
              child: Container(
                width: chip,
                height: chip,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: entry.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? Colors.black87 : Colors.transparent, width: 4),
                ),
                child: done
                    ? Icon(Icons.check, color: Colors.white, size: chip * 0.45)
                    : Text(
                        _lang.numberText(entry.number),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: chip * 0.48,
                          fontWeight: FontWeight.bold,
                          shadows: const [Shadow(color: Colors.black38, blurRadius: 2)],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: chip + gap - 2,
            child: Text(
              _lang.colorText(entry.name),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final count = _inCategory.length;
    final hasPrev = _pageIndex > 0;
    final hasNext = _pageIndex < count - 1;

    Widget button(IconData icon, bool enabled, VoidCallback onTap, Color color) {
      return Expanded(
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: enabled ? color : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, size: 26, color: enabled ? (color == Colors.white ? Colors.black : Colors.white) : Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          button(Icons.chevron_left, hasPrev, _prev, Colors.white),
          Expanded(
            child: Text(
              '${_pageIndex + 1} / $count',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          button(Icons.chevron_right, hasNext, _next, Colors.orange),
        ],
      ),
    );
  }
}

class _ColoringPainter extends CustomPainter {
  final CbnPage page;
  final Set<String> filled;
  final KidsLanguage lang;

  _ColoringPainter(this.page, this.filled, this.lang);

  @override
  void paint(Canvas canvas, Size size) {
    final fit = CbnFit.of(page.viewBox, size);
    canvas.save();
    canvas.translate(fit.offset.dx, fit.offset.dy);
    canvas.scale(fit.scale);

    cbnPaintPage(canvas, page, filled: filled);

    // numbers (in the language's digits) and hint dots on empty regions
    for (final r in page.regions) {
      if (filled.contains(r.id)) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: lang.numberText(r.number),
          style: TextStyle(fontSize: r.labelSize, fontWeight: FontWeight.bold, color: const Color(0xFF555555)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, r.label - Offset(tp.width / 2, tp.height / 2));

      if (page.showColorHints) {
        final radius = math.max(r.labelSize * 0.16, 7.0);
        canvas.drawCircle(
          r.label + Offset(0, r.labelSize * 0.78),
          radius,
          Paint()..color = page.colorFor(r.number),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ColoringPainter old) =>
      old.page != page || old.filled.length != filled.length || old.lang != lang;
}
