import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'drawing.dart';
import 'models.dart';
import 'tracing_guide.dart';
import 'traffic_sign_widget.dart';
import 'alphabet_images_view.dart';
import 'sound_help_sheet.dart';
import 'month_illustration.dart';

class TracingScreen extends StatefulWidget {
  const TracingScreen({required this.category, super.key});
  final Category category;

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  final DrawingModel _drawing = DrawingModel();
  final ScrollController _stripController = ScrollController();
  final GlitterController _glitter = GlitterController();

  int _index = 0;
  bool _showLowercase = false;
  bool _brushChosenByUser = false;

  late List<TraceItem> _items;
  late AppLanguage _language;

  @override
  void initState() {
    super.initState();
    final lp = context.read<LanguageProvider>();
    _language = lp.currentLanguage;
    _items = lp.itemsFor(widget.category);
    _drawing.addListener(_watchBrushChanges);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyItemDefaults();
      Future.delayed(const Duration(milliseconds: 300), _speak);
    });
  }

  @override
  void dispose() {
    _drawing.removeListener(_watchBrushChanges);
    _drawing.dispose();
    _stripController.dispose();
    _glitter.dispose();
    super.dispose();
  }

  double? _lastKnownWidth;
  bool _applyingDefaults = false;

  void _watchBrushChanges() {
    if (_lastKnownWidth != null &&
        _lastKnownWidth != _drawing.lineWidth &&
        !_applyingDefaults) {
      _brushChosenByUser = true;
    }
    _lastKnownWidth = _drawing.lineWidth;
  }

  TraceItem get _item => _items[_index];

  bool get _showItemStrip {
    switch (widget.category) {
      case Category.alphabets:
      case Category.numbers:
      case Category.colors:
      case Category.shapes:
        return true;
      case Category.words:
      case Category.days:
      case Category.months:
      case Category.trafficSigns:
      case Category.sounds:
      case Category.xylophone:
      case Category.lines:
        return false;
    }
  }

  bool get _isTrafficSign =>
      _item.shapeKey?.startsWith('traffic_') == true;

  String get _signKey =>
      _item.shapeKey?.replaceFirst('traffic_', '') ?? 'stop';

  bool get _showAlphabetImages =>
      widget.category == Category.alphabets && _language.id == 'en';

  String get _displayText {
    final text = _item.display;
    if (!_language.hasLetterCase ||
        widget.category != Category.alphabets ||
        text == 'ß') return text;
    return _showLowercase ? text.toLowerCase() : text.toUpperCase();
  }

  double _autoLineWidth(String text) {
    final l = text.runes.length;
    if (l <= 2) return 18;
    if (l <= 5) return 11;
    return 6;
  }

  void _speak() {
    if (!mounted) return;
    var text = _item.spoken;
    if (_language.hasLetterCase && widget.category == Category.alphabets) {
      text = text.toLowerCase();
    }
    context.read<TTSProvider>().speak(text, _language.speechCode);
  }

  void _applyItemDefaults() {
    _applyingDefaults = true;
    final color = ItemColors.get(_item.colorKey);
    if (color != null) _drawing.setColor(color);
    if (!_brushChosenByUser) {
      _drawing.setLineWidth(_autoLineWidth(_displayText));
    }
    _lastKnownWidth = _drawing.lineWidth;
    _applyingDefaults = false;
  }

  void _go(int newIndex) {
    if (newIndex < 0 || newIndex >= _items.length) return;
    if (_drawing.strokes.isNotEmpty) {
      context.read<ProgressProvider>().markComplete(
          _language.id, widget.category, _item.display);
    }
    setState(() => _index = newIndex);
    _drawing.clear();
    _glitter.clear();
    _applyItemDefaults();
    Future.delayed(const Duration(milliseconds: 200), _speak);
    _scrollStripTo(newIndex);
  }

  void _scrollStripTo(int index) {
    if (!_stripController.hasClients) return;
    const itemExtent = 52.0;
    final target = (index * itemExtent) -
        (MediaQuery.of(context).size.width / 2) +
        (itemExtent / 2);
    _stripController.animateTo(
      target.clamp(0.0, _stripController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ── Corner image card helper for landscape ───────────────────────────

  Widget _cornerImageCard(String name, {required String letter}) {
    return GestureDetector(
      onTap: () {
        context.read<TTSProvider>().speak(name, _language.speechCode);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/$letter/$name.webp',
              width: 54,
              height: 54,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_outlined,
                size: 38,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Canvas widget ────────────────────────────────────────────────────

  Widget _canvasWidget() {
    final isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    // In Landscape with Alphabet images: place letter in middle, 4 items in 4 corners
    final letterKey = _item.display.toUpperCase();
    final words = AlphabetImageRegistry.images[letterKey] ?? const <String>[];
    final showCornerImages = isLandscape && _showAlphabetImages && words.length >= 4;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white.withOpacity(0.35),
        child: GestureDetector(
          onPanUpdate: (d) => _glitter.addAt(d.localPosition),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _canvasContent(),
                ),
              ),

              // 4 Corner Alphabet images in Landscape mode
              if (showCornerImages) ...[
                Positioned(
                  top: 10,
                  left: 10,
                  child: _cornerImageCard(words[0], letter: _item.display),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _cornerImageCard(words[1], letter: _item.display),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: _cornerImageCard(words[2], letter: _item.display),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _cornerImageCard(words[3], letter: _item.display),
                ),
              ],

              Positioned.fill(child: DrawingCanvas(model: _drawing)),
              Positioned.fill(
                child: IgnorePointer(
                  child: GlitterOverlay(controller: _glitter),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _canvasContent() {
    if (_isTrafficSign) {
      return LayoutBuilder(builder: (_, c) {
        final sz = c.maxHeight.isInfinite
            ? c.maxWidth * 0.6
            : c.maxHeight * 0.6;
        return Center(
          child: TrafficSignWidget(
            signKey: _signKey,
            label: _item.display,
            size: sz.clamp(80, 280),
          ),
        );
      });
    }
    if (_item.shapeKey != null) {
      return Column(children: [
        Expanded(child: DottedShape(shapeKey: _item.shapeKey!)),
        Text(_item.display,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 4),
      ]);
    }

    if (widget.category == Category.months) {
      final isLandscape = MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height;
      final size = MediaQuery.of(context).size.shortestSide *
          (isLandscape ? 0.55 : 0.35);

      if (isLandscape) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: MonthIllustration(
                  monthIndex: _index % 12,
                  monthName: _item.display,
                  size: size,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: DottedText(text: _displayText),
            ),
          ],
        );
      }

      return Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: MonthIllustration(
                monthIndex: _index % 12,
                monthName: _item.display,
                size: size,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DottedText(text: _displayText),
          ),
        ],
      );
    }

    return DottedText(text: _displayText);
  }

  // ── Controls row ─────────────────────────────────────────────────────

  Widget _controlsRow() {
    final canPrev = _index > 0;
    final canNext = _index < _items.length - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _arrow(Icons.arrow_circle_left, canPrev, () => _go(_index - 1)),
        const SizedBox(width: 32),
        _arrow(Icons.arrow_circle_right, canNext, () => _go(_index + 1)),
      ],
    );
  }

  Widget _arrow(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(icon,
          size: 50,
          color: enabled ? Colors.green : Colors.grey.withOpacity(0.4)),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _header() {
    final itemColor = ItemColors.get(_item.colorKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('${_index + 1}/${_items.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13)),
          ),
          if (itemColor != null)
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          const Spacer(),
          if (_language.hasLetterCase && widget.category == Category.alphabets)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () {
                  setState(() => _showLowercase = !_showLowercase);
                  _drawing.clear();
                  _applyItemDefaults();
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_showLowercase ? 'abc' : 'ABC',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
            ),
          _circleButton(Icons.replay, Colors.blue, _speak),
          const SizedBox(width: 6),
          _circleButton(Icons.delete, Colors.orange, () {
            _drawing.clear();
            _glitter.clear();
          }),
        ],
      ),
    );
  }

  // ── Item strip ────────────────────────────────────────────────────────

  Widget _itemStrip() {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.separated(
        controller: _stripController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final item = _items[i];
          final selected = i == _index;
          final shape = ShapeIcons.get(item.shapeKey);
          return GestureDetector(
            onTap: () => _go(i),
            child: AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? widget.category.tint
                      : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: shape != null
                    ? Icon(shape,
                    size: 16,
                    color: selected ? Colors.white : Colors.black87)
                    : FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      item.display,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: item.display.length > 3 ? 10 : 15,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Palette section ───────────────────────────────────────────────────

  Widget _palette() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrushPalette(model: _drawing),
        const SizedBox(height: 2),
        ColorPalette(model: _drawing),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────

  Widget _footer() {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, size: 12, color: Colors.blue),
            SizedBox(width: 4),
            Text('Sound Help',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  // ── Main build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.title)),
        body: const Center(child: Text('No content for this language yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.category.localizedTitle(_language.id)),
        centerTitle: true,
        toolbarHeight: 44,
        actions: [
          Consumer<TTSProvider>(
            builder: (_, tts, __) => IconButton(
              icon: Icon(tts.isMuted ? Icons.volume_off : Icons.volume_up),
              color: tts.isMuted ? Colors.red : null,
              iconSize: 20,
              onPressed: tts.toggleMute,
            ),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: BackgroundPalette.at(_index),
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

  // ── Portrait layout ───────────────────────────────────────────────────

  Widget _portraitLayout() {
    return Column(
      children: [
        _header(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _canvasWidget(),
          ),
        ),
        const SizedBox(height: 4),
        if (_showAlphabetImages)
          AlphabetImagesView(
            key: ValueKey('img_$_index'),
            letter: _item.display,
            language: _language,
          )
        else
          _palette(),
        if (_showItemStrip) _itemStrip(),
        const SizedBox(height: 4),
        _controlsRow(),
        const SizedBox(height: 4),
        _footer(),
        const SizedBox(height: 6),
      ],
    );
  }

  // ── Landscape layout ──────────────────────────────────────────────────

  Widget _landscapeLayout() {
    return Row(
      children: [
        // Left: canvas with center alphabet and 4 corner cards
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 6, 8),
            child: Column(
              children: [
                _header(),
                Expanded(child: _canvasWidget()),
              ],
            ),
          ),
        ),

        // Right: controls and palette
        SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 12, 8),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('${_index + 1} / ${_items.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      BrushPalette(model: _drawing),
                      const SizedBox(height: 4),
                      ColorPalette(model: _drawing),
                    ],
                  ),
                ),
                const Spacer(),
                if (_language.hasLetterCase &&
                    widget.category == Category.alphabets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showLowercase = !_showLowercase);
                        _drawing.clear();
                        _applyItemDefaults();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _showLowercase ? 'abc' : 'ABC',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                _circleButton(
                    Icons.arrow_circle_left,
                    _index > 0 ? Colors.green : Colors.grey.withOpacity(0.4),
                        () => _go(_index - 1)),
                const SizedBox(height: 8),
                _circleButton(
                    Icons.arrow_circle_right,
                    _index < _items.length - 1
                        ? Colors.green
                        : Colors.grey.withOpacity(0.4),
                        () => _go(_index + 1)),
                const SizedBox(height: 8),
                _footer(),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}