import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'drawing.dart';
import 'models.dart';
import 'tracing_guide.dart';

/// The main learning screen: a large "ghost" character/word the child traces
/// over with a finger. Background color changes with every item and the sound
/// plays automatically (and on demand via the speaker button).
class TracingScreen extends StatefulWidget {
  const TracingScreen({required this.category, super.key});

  final Category category;

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  final DrawingModel _drawing = DrawingModel();
  final ScrollController _stripController = ScrollController();

  int _index = 0;
  bool _showLowercase = false;
  late List<TraceItem> _items;
  late AppLanguage _language;

  @override
  void initState() {
    super.initState();
    final lp = context.read<LanguageProvider>();
    _language = lp.currentLanguage;
    _items = lp.itemsFor(widget.category);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyItemColor();
      _speak();
    });
  }

  @override
  void dispose() {
    _drawing.dispose();
    _stripController.dispose();
    super.dispose();
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
        return false;
    }
  }

  String get _displayText {
    final text = _item.display;
    if (!_language.hasLetterCase ||
        widget.category != Category.alphabets ||
        text == 'ß') {
      return text;
    }
    return _showLowercase ? text.toLowerCase() : text.toUpperCase();
  }

  void _speak() {
    var text = _item.spoken;
    if (_language.hasLetterCase && widget.category == Category.alphabets) {
      text = text.toLowerCase();
    }
    context.read<TTSProvider>().speak(text, _language.speechCode);
  }

  void _applyItemColor() {
    final color = ItemColors.get(_item.colorKey);
    if (color != null) _drawing.setColor(color);
  }

  void _go(int newIndex) {
    if (newIndex < 0 || newIndex >= _items.length) return;

    // Credit the item if the child actually drew on it.
    if (_drawing.strokes.isNotEmpty) {
      context
          .read<ProgressProvider>()
          .markComplete(_language.id, widget.category, _item.display);
    }

    setState(() => _index = newIndex);
    _drawing.clear();
    _applyItemColor();
    _speak();
    _scrollStripTo(newIndex);
  }

  void _scrollStripTo(int index) {
    if (!_stripController.hasClients) return;
    const itemExtent = 52.0; // 44 wide + 8 spacing
    final target = (index * itemExtent) -
        (MediaQuery.of(context).size.width / 2) +
        (itemExtent / 2);
    _stripController.animateTo(
      target.clamp(0.0, _stripController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.title)),
        body: const Center(child: Text('No content for this language yet.')),
      );
    }

    final canvasHeight = MediaQuery.of(context).size.height * 0.38;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.category.localizedTitle(_language.id)),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: BackgroundPalette.at(_index),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: canvasHeight,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.35),
                    child: Stack(
                      children: [
                        // Guide layer
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _item.shapeKey != null
                                ? Column(
                              children: [
                                Expanded(
                                  child: DottedShape(
                                      shapeKey: _item.shapeKey!),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _item.display,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : DottedText(text: _displayText),
                          ),
                        ),
                        // Drawing layer on top
                        Positioned.fill(
                          child: DrawingCanvas(model: _drawing),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ColorPalette(model: _drawing),
              const Spacer(),
              if (_showItemStrip) _itemStrip(),
              const SizedBox(height: 8),
              _controls(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- Header

  Widget _header() {
    final itemColor = ItemColors.get(_item.colorKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_index + 1} / ${_items.length}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          if (itemColor != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          const Spacer(),
          if (_language.hasLetterCase &&
              widget.category == Category.alphabets)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _showLowercase = !_showLowercase);
                  _drawing.clear();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    _showLowercase ? 'abc' : 'ABC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          _circleButton(Icons.volume_up, Colors.blue, _speak),
          const SizedBox(width: 8),
          _circleButton(Icons.delete, Colors.orange, _drawing.clear),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // ------------------------------------------------------------- Strip

  Widget _itemStrip() {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        controller: _stripController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = _items[i];
          final selected = i == _index;
          final shape = ShapeIcons.get(item.shapeKey);

          return GestureDetector(
            onTap: () => _go(i),
            child: AnimatedScale(
              scale: selected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? widget.category.tint
                      : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: shape != null
                    ? Icon(shape,
                    size: 18,
                    color: selected ? Colors.white : Colors.black87)
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FittedBox(
                    child: Text(
                      item.display,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: item.display.length > 3 ? 11 : 16,
                        fontWeight: FontWeight.bold,
                        color:
                        selected ? Colors.white : Colors.black87,
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

  // ------------------------------------------------------------- Controls

  Widget _controls() {
    final canPrev = _index > 0;
    final canNext = _index < _items.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _arrow(Icons.arrow_circle_left, canPrev, () => _go(_index - 1)),
        const SizedBox(width: 40),
        _arrow(Icons.arrow_circle_right, canNext, () => _go(_index + 1)),
      ],
    );
  }

  Widget _arrow(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: 54,
        color: enabled ? Colors.green : Colors.grey.withOpacity(0.4),
      ),
    );
  }
}