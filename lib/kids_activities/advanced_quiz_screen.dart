import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'activity_strings.dart';
import 'advanced_quiz.dart';
import 'cbn_models.dart';
import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

/// One screen for all Advanced activities: 10 questions a round, then a
/// score and "10 more". Questions never repeat until all have been seen.
class AdvancedQuizScreen extends StatefulWidget {
  final AdvancedActivity activity;
  final KidsLanguage language;

  const AdvancedQuizScreen({super.key, required this.activity, this.language = KidsLanguage.english});

  @override
  State<AdvancedQuizScreen> createState() => _AdvancedQuizScreenState();
}

class _AdvancedQuizScreenState extends State<AdvancedQuizScreen> {
  final _random = math.Random();
  bool _loading = true;
  int _level = 3;
  int _round = 0;
  List<AdvQuestion> _questions = [];
  int _index = 0;
  int _score = 0;
  final Set<String> _wrong = {};
  bool _solved = false;
  bool _missed = false;
  bool _finished = false;
  int _shake = 0;
  final List<KidsBurst> _bursts = [];
  Size _boardSize = const Size(360, 600);

  KidsLanguage get _lang => widget.language;

  AdvQuestion? get _current => _index < _questions.length ? _questions[_index] : null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _level = await KidsAge.load();
    await KidsGamePictures.load();
    await KidsGameSound.instance.start();
    await _newRound();
  }

  @override
  void dispose() {
    KidsGameSound.instance.stop();
    KidsGameServices.stopSpeaking();
    super.dispose();
  }

  Future<void> _newRound() async {
    _round++;
    final questions = await AdvancedQuestionBuilder(widget.activity, _lang, _level).makeRound(count: 10);
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _index = 0;
      _score = 0;
      _finished = false;
      _loading = false;
      _resetQuestion();
    });
  }

  void _resetQuestion() {
    _wrong.clear();
    _solved = false;
    _missed = false;
    _bursts.clear();
  }

  void _setLevel(int level) {
    if (level == _level) return;
    KidsAge.set(level);
    _level = level;
    _newRound();
  }

  /// The word activity is English in every language.
  Future<void> _speak(String text) {
    if (widget.activity == AdvancedActivity.missingWordLetter) {
      return KidsGameServices.speak(text, 'en-US');
    }
    return _lang.speak(text);
  }

  // MARK: - Answering

  void _answer(AdvChoice choice) {
    final q = _current;
    if (q == null || _solved || _finished) return;

    if (choice.id == q.answerId) {
      setState(() {
        _solved = true;
        if (!_missed) _score++;
      });
      KidsGameSound.instance.jingle();
      HapticFeedback.mediumImpact();
      _addBurst(Offset(_boardSize.width / 2, _boardSize.height * 0.4));
      _addBurst(_randomPoint());
      _speak(q.spokenAnswer);

      final round = _round;
      Timer(const Duration(milliseconds: 1600), () {
        if (!mounted || round != _round) return;
        _next();
      });
    } else {
      setState(() {
        _missed = true;
        _wrong.add(choice.id);
        _shake++;
      });
      KidsGameSound.instance.boop();
      HapticFeedback.lightImpact();
    }
  }

  void _next() {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _resetQuestion();
      });
    } else {
      setState(() => _finished = true);
      KidsGameSound.instance.jingle();
      HapticFeedback.heavyImpact();
      _lang.speak(CbnStrings.praiseFor(_lang.id));
      for (var i = 0; i < 5; i++) {
        _addBurst(_randomPoint());
      }
    }
  }

  Offset _randomPoint() => Offset(
        (0.15 + _random.nextDouble() * 0.7) * _boardSize.width,
        (0.15 + _random.nextDouble() * 0.7) * _boardSize.height,
      );

  void _addBurst(Offset center) {
    final burst = KidsBurst(
      center: center,
      colors: const [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink],
      count: 20,
      distance: 150,
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
        title: Text(ActivityStrings.local(widget.activity.name, _lang.id) ?? widget.activity.title),
        actions: [
          KidsAgeMenu(level: _level, onSelect: _setLevel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _newRound),
        ],
      ),
      body: KidsGameBackground(
        colors: const [Color(0xFFFFFAED), Color(0xFFEDF5FF)],
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(builder: (context, c) {
                    _boardSize = Size(c.maxWidth, c.maxHeight);
                    final q = _current;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: _finished
                              ? _results()
                              : (q == null ? const SizedBox() : _questionView(q, c.maxWidth)),
                        ),
                        Positioned.fill(child: KidsBurstLayer(bursts: List.of(_bursts))),
                      ],
                    );
                  }),
                ),
        ),
      ),
    );
  }

  Widget _questionView(AdvQuestion q, double width) {
    return KidsShake(
      trigger: _shake,
      child: Column(
        children: [
          _progressDots(),
          const Spacer(),
          _prompt(q, width),
          const Spacer(),
          _choices(q, width),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _progressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _questions.length; i++)
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _index ? Colors.green : (i == _index ? Colors.orange : Colors.grey.withOpacity(0.25)),
            ),
          ),
      ],
    );
  }

  /// What fills the blank: the answer once solved, otherwise a "?" box.
  AdvToken _shown(AdvToken token, AdvQuestion q) {
    if (token == AdvToken.blank && _solved) {
      return q.answer?.token ?? token;
    }
    return token;
  }

  Widget _prompt(AdvQuestion q, double width) {
    final p = q.prompt;
    switch (p.kind) {
      case AdvPromptKind.row:
        final gap = p.tight ? 6.0 : 12.0;
        final n = math.max(p.tokens.length, 1);
        final size = math.min(84.0, (width - gap * (n - 1)) / n);
        return Directionality(
          textDirection: p.rightToLeft ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < p.tokens.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                _tokenView(_shown(p.tokens[i], q), size),
              ],
            ],
          ),
        );

      case AdvPromptKind.count:
        return _pictureGroup(p.subject, p.a, width, p.a > 10 ? 50 : 62);

      case AdvPromptKind.arithmetic:
        final side = (width - 70) / 2;
        const big = TextStyle(fontSize: 34, fontWeight: FontWeight.w900);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(mainAxisSize: MainAxisSize.min, children: [
                  _pictureGroup(p.subject, p.a, side, 36),
                  Text(p.aText, style: big),
                ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(p.plus ? '+' : '−', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  _pictureGroup(p.subject, p.b, side, 36),
                  Text(p.bText, style: big),
                ]),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('=', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
                const SizedBox(width: 12),
                _tokenView(_shown(AdvToken.blank, q), 80),
              ],
            ),
          ],
        );

      case AdvPromptKind.findOdd:
        return const Icon(Icons.search, size: 60, color: Colors.purple);
    }
  }

  Widget _choices(AdvQuestion q, double width) {
    if (q.prompt.kind == AdvPromptKind.findOdd) {
      final size = math.min(150.0, (width - 20) / 2);
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [for (final c in q.choices) _choiceButton(c, q, size)],
      );
    }
    final size = math.min(96.0, (width - 40) / math.max(q.choices.length, 1));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < q.choices.length; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          _choiceButton(q.choices[i], q, size),
        ],
      ],
    );
  }

  Widget _choiceButton(AdvChoice choice, AdvQuestion q, double size) {
    final wrong = _wrong.contains(choice.id);
    final isAnswer = _solved && choice.id == q.answerId;
    return GestureDetector(
      onTap: (wrong || _solved) ? null : () => _answer(choice),
      child: AnimatedScale(
        scale: isAnswer ? 1.1 : 1,
        duration: const Duration(milliseconds: 250),
        child: Opacity(
          opacity: wrong ? 0.3 : 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.22 + 4),
              border: Border.all(color: isAnswer ? Colors.green : Colors.transparent, width: 4),
            ),
            child: _tokenView(choice.token, size),
          ),
        ),
      ),
    );
  }

  // MARK: - Pieces

  Widget _tokenView(AdvToken token, double size) {
    final radius = BorderRadius.circular(size * 0.22);
    final card = BoxDecoration(
      color: Colors.white,
      borderRadius: radius,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
    );

    switch (token.kind) {
      case AdvKind.blank:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            borderRadius: radius,
            border: Border.all(color: Colors.orange, width: 3),
          ),
          child: Text('?',
              style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.w900, color: Colors.orange)),
        );
      case AdvKind.text:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          padding: EdgeInsets.all(size * 0.08),
          decoration: card,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(token.value,
                style: TextStyle(fontSize: size * 0.55, fontWeight: FontWeight.w900, color: const Color(0xFF26264D))),
          ),
        );
      case AdvKind.symbol:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
            borderRadius: radius,
          ),
          child: Text(token.value,
              style: TextStyle(fontSize: size * 0.6, fontWeight: FontWeight.w900, color: Colors.white)),
        );
      case AdvKind.picture:
        final page = KidsGamePictures.bySubject[token.value];
        return Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.12),
          decoration: card,
          child: page == null ? null : KidsGamePicture(page: page),
        );
      case AdvKind.color:
        return Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.14),
          decoration: card,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cbnHex(AdvancedQuestionBuilder.colorHex[token.value] ?? '#9E9E9E'),
            ),
          ),
        );
    }
  }

  /// n copies of a picture, wrapped five to a row.
  Widget _pictureGroup(String subject, int n, double maxWidth, double itemSize) {
    final page = KidsGamePictures.bySubject[subject];
    final perRow = math.max(1, math.min(5, (maxWidth / (itemSize + 6)).floor()));
    return SizedBox(
      width: math.min(n, perRow) * (itemSize + 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 0; i < n; i++)
            SizedBox(width: itemSize, height: itemSize, child: page == null ? null : KidsGamePicture(page: page)),
        ],
      ),
    );
  }

  // MARK: - Results

  Widget _results() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⭐️', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 12),
        Text('${_lang.numberText(_score)} / ${_lang.numberText(_questions.length)}',
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _questions.length; i++)
              Icon(i < _score ? Icons.star : Icons.star_border, color: Colors.amber, size: 26),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _newRound,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFB923C), Color(0xFFF97316)]),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(_lang.numberText(10),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
