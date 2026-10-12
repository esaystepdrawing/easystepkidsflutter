import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cbn_strings.dart';
import 'kids_game_shared.dart';
import 'kids_language.dart';

// Advanced tab: eight quiz activities that share one question model,
// one screen (AdvancedQuizScreen) and a "never repeat" memory per age.

// MARK: - Activities

enum AdvancedActivity {
  nextNumber,
  compare,
  missingLetter,
  missingWordLetter,
  count,
  addSubtract,
  oddOneOut,
  pattern,
}

extension AdvancedActivityInfo on AdvancedActivity {
  String get title {
    switch (this) {
      case AdvancedActivity.nextNumber:
        return 'Next Number';
      case AdvancedActivity.compare:
        return 'Bigger or Smaller';
      case AdvancedActivity.missingLetter:
        return 'Missing Letter';
      case AdvancedActivity.missingWordLetter:
        return 'Missing Letter in Words';
      case AdvancedActivity.count:
        return 'Count the Pictures';
      case AdvancedActivity.addSubtract:
        return 'Add & Take Away';
      case AdvancedActivity.oddOneOut:
        return 'Odd One Out';
      case AdvancedActivity.pattern:
        return 'What Comes Next?';
    }
  }

  IconData get icon {
    switch (this) {
      case AdvancedActivity.nextNumber:
        return Icons.format_list_numbered;
      case AdvancedActivity.compare:
        return Icons.compare_arrows;
      case AdvancedActivity.missingLetter:
        return Icons.abc;
      case AdvancedActivity.missingWordLetter:
        return Icons.menu_book;
      case AdvancedActivity.count:
        return Icons.filter_9_plus;
      case AdvancedActivity.addSubtract:
        return Icons.calculate;
      case AdvancedActivity.oddOneOut:
        return Icons.search;
      case AdvancedActivity.pattern:
        return Icons.repeat;
    }
  }

  List<Color> get colors {
    switch (this) {
      case AdvancedActivity.nextNumber:
        return const [Color(0xFFF97316), Color(0xFFEF4444)];
      case AdvancedActivity.compare:
        return const [Color(0xFF3B82F6), Color(0xFF6366F1)];
      case AdvancedActivity.missingLetter:
        return const [Color(0xFF14B8A6), Color(0xFF3B82F6)];
      case AdvancedActivity.missingWordLetter:
        return const [Color(0xFF22C55E), Color(0xFF14B8A6)];
      case AdvancedActivity.count:
        return const [Color(0xFFEC4899), Color(0xFFF97316)];
      case AdvancedActivity.addSubtract:
        return const [Color(0xFFA855F7), Color(0xFFEC4899)];
      case AdvancedActivity.oddOneOut:
        return const [Color(0xFF6366F1), Color(0xFFA855F7)];
      case AdvancedActivity.pattern:
        return const [Color(0xFFEAB308), Color(0xFFF97316)];
    }
  }
}

/// Words are English only; the Chinese "alphabet" has no fixed order.
List<AdvancedActivity> advancedActivitiesFor(String languageId) {
  return AdvancedActivity.values.where((a) {
    switch (a) {
      case AdvancedActivity.missingWordLetter:
        return languageId == 'en';
      case AdvancedActivity.missingLetter:
        return languageId != 'zh';
      default:
        return true;
    }
  }).toList();
}

// MARK: - Question model

enum AdvKind { text, blank, picture, color, symbol }

class AdvToken {
  final AdvKind kind;
  final String value;

  const AdvToken(this.kind, [this.value = '']);

  static const blank = AdvToken(AdvKind.blank);

  String get id => '${kind.name}:$value';

  @override
  bool operator ==(Object other) => other is AdvToken && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

class AdvChoice {
  final AdvToken token;
  final String spoken;

  const AdvChoice(this.token, this.spoken);

  String get id => token.id;
}

enum AdvPromptKind { row, count, arithmetic, findOdd }

class AdvPrompt {
  final AdvPromptKind kind;
  final List<AdvToken> tokens;
  final bool tight;
  final bool rightToLeft;
  final String subject;
  final int a;
  final int b;
  final bool plus;
  final String aText;
  final String bText;

  const AdvPrompt.row(this.tokens, {this.tight = false, this.rightToLeft = false})
      : kind = AdvPromptKind.row,
        subject = '',
        a = 0,
        b = 0,
        plus = true,
        aText = '',
        bText = '';

  const AdvPrompt.count(this.subject, this.a)
      : kind = AdvPromptKind.count,
        tokens = const [],
        tight = false,
        rightToLeft = false,
        b = 0,
        plus = true,
        aText = '',
        bText = '';

  const AdvPrompt.arithmetic(this.a, this.plus, this.b, this.subject, this.aText, this.bText)
      : kind = AdvPromptKind.arithmetic,
        tokens = const [],
        tight = false,
        rightToLeft = false;

  const AdvPrompt.findOdd()
      : kind = AdvPromptKind.findOdd,
        tokens = const [],
        tight = false,
        rightToLeft = false,
        subject = '',
        a = 0,
        b = 0,
        plus = true,
        aText = '',
        bText = '';
}

class AdvQuestion {
  /// Identifies the question for the "never repeat" memory.
  final String key;
  final AdvPrompt prompt;
  final List<AdvChoice> choices;
  final String answerId;

  /// Said aloud when the child gets it right.
  final String spokenAnswer;

  const AdvQuestion({
    required this.key,
    required this.prompt,
    required this.choices,
    required this.answerId,
    required this.spokenAnswer,
  });

  AdvChoice? get answer {
    for (final c in choices) {
      if (c.id == answerId) return c;
    }
    return null;
  }
}

// MARK: - Never repeat

class AdvancedSeenStore {
  static String _key(AdvancedActivity a, String languageId, int level) =>
      'advancedSeen.${a.name}.$languageId.$level';

  static Future<Set<String>> load(AdvancedActivity a, String languageId, int level) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key(a, languageId, level)) ?? const <String>[]).toSet();
  }

  static Future<void> save(Set<String> seen, AdvancedActivity a, String languageId, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key(a, languageId, level), seen.toList());
  }
}

// MARK: - Question builder

class AdvancedQuestionBuilder {
  final AdvancedActivity activity;
  final KidsLanguage language;
  final int level;
  final _r = math.Random();

  AdvancedQuestionBuilder(this.activity, this.language, this.level);

  static const colorHex = {
    'red': '#E53935', 'orange': '#FB8C00', 'yellow': '#FDD835', 'green': '#43A047',
    'blue': '#1E88E5', 'purple': '#8E24AA', 'pink': '#F48FB1', 'brown': '#8D6E63',
  };

  static const words3 = [
    'cat', 'dog', 'sun', 'hat', 'cup', 'bus', 'fox', 'pig', 'cow', 'hen', 'bee', 'ant', 'owl',
    'bat', 'egg', 'jam', 'pen', 'bed', 'box', 'car', 'van', 'map', 'net', 'pot', 'rat', 'web',
    'mop', 'bag', 'cap', 'fan', 'fig', 'jet', 'log', 'mug', 'nut', 'pan', 'rug', 'toy', 'key',
    'sea', 'arm', 'leg', 'ear', 'eye', 'lip', 'hug', 'red', 'top', 'mat', 'dot',
  ];
  static const words4 = [
    'ball', 'fish', 'star', 'moon', 'tree', 'book', 'door', 'frog', 'duck', 'cake', 'kite',
    'lion', 'bear', 'ship', 'milk', 'rain', 'nest', 'coat', 'bell', 'boat', 'corn', 'drum',
    'gift', 'hand', 'king', 'lamp', 'leaf', 'nose', 'ring', 'rose', 'sock', 'tent', 'wolf',
    'worm', 'bird', 'fork', 'goat', 'hill', 'desk', 'shoe',
  ];

  T _pick<T>(List<T> list) => list[_r.nextInt(list.length)];

  int _between(int lo, int hi) => lo + _r.nextInt(hi - lo + 1);

  // MARK: Round

  /// [count] new questions, skipping ones this child has already seen.
  /// When everything has been seen, the memory starts over.
  Future<List<AdvQuestion>> makeRound({int count = 10}) async {
    final seen = await AdvancedSeenStore.load(activity, language.id, level);
    final round = <AdvQuestion>[];
    final usedThisRound = <String>{};
    var tries = 0;

    while (round.length < count && tries < 600) {
      tries++;
      final q = makeQuestion();
      if (q == null || usedThisRound.contains(q.key)) continue;
      if (seen.contains(q.key)) {
        if (tries % 150 == 0) seen.clear();
        continue;
      }
      usedThisRound.add(q.key);
      seen.add(q.key);
      round.add(q);
    }
    await AdvancedSeenStore.save(seen, activity, language.id, level);
    return round;
  }

  AdvQuestion? makeQuestion() {
    switch (activity) {
      case AdvancedActivity.nextNumber:
        return _nextNumber();
      case AdvancedActivity.compare:
        return _compare();
      case AdvancedActivity.missingLetter:
        return _missingLetter();
      case AdvancedActivity.missingWordLetter:
        return _missingWordLetter();
      case AdvancedActivity.count:
        return _count();
      case AdvancedActivity.addSubtract:
        return _addSubtract();
      case AdvancedActivity.oddOneOut:
        return _oddOneOut();
      case AdvancedActivity.pattern:
        return _pattern();
    }
  }

  // MARK: Helpers

  /// Largest number with a word in this language (some stop at 10).
  int get _maxNumber => math.max(5, language.numberDisplay.length - 1);

  AdvChoice _numberChoice(int n) => AdvChoice(AdvToken(AdvKind.text, language.numberText(n)), language.numberWord(n));

  /// The answer plus two nearby wrong numbers, shuffled.
  List<AdvChoice> _numberChoices(int answer, int lo, int hi) {
    final options = <int>{answer};
    final near = [answer - 1, answer + 1, answer - 2, answer + 2, answer + 3, answer - 3]
        .where((n) => n >= lo && n <= hi)
        .toList()
      ..shuffle(_r);
    for (final n in near) {
      if (options.length >= 3) break;
      options.add(n);
    }
    while (options.length < 3) {
      options.add(_between(lo, hi));
    }
    final list = options.toList()..shuffle(_r);
    return list.map(_numberChoice).toList();
  }

  bool get _rightToLeft => language.id == 'ur' || language.id == 'ar';

  List<String> get _subjects =>
      CbnStrings.subjects.where((s) => KidsGamePictures.bySubject.containsKey(s)).toList();

  String _title(String subject) => KidsGamePictures.title(subject, language.id);

  // MARK: Next Number: 2 3 _ 5

  AdvQuestion? _nextNumber() {
    final top = level <= 3 ? math.min(10, _maxNumber) : math.min(20, _maxNumber);
    const length = 4;
    if (top - length + 1 < 1) return null;
    final descending = level >= 5 && _r.nextBool();
    final start = _between(1, top - length + 1);
    var seq = List.generate(length, (i) => start + i);
    if (descending) seq = seq.reversed.toList();
    final blank = level <= 3 ? length - 1 : _r.nextInt(length);
    final answer = seq[blank];

    return AdvQuestion(
      key: '${seq.join(',')}|$blank',
      prompt: AdvPrompt.row([
        for (var i = 0; i < length; i++)
          i == blank ? AdvToken.blank : AdvToken(AdvKind.text, language.numberText(seq[i])),
      ]),
      choices: _numberChoices(answer, 0, top),
      answerId: AdvToken(AdvKind.text, language.numberText(answer)).id,
      spokenAnswer: language.numberWord(answer),
    );
  }

  // MARK: Bigger or Smaller: 7 _ 12  ->  <  =  >

  AdvQuestion _compare() {
    final top = level <= 3
        ? math.min(10, _maxNumber)
        : (level == 4 ? math.min(15, _maxNumber) : math.min(20, _maxNumber));
    final a = _between(0, top);
    final b = _r.nextInt(10) < 2 ? a : _between(0, top); // about 1 in 5 are equal
    final answer = a < b ? '<' : (a > b ? '>' : '=');

    return AdvQuestion(
      key: '$a-$b',
      prompt: AdvPrompt.row([
        AdvToken(AdvKind.text, language.numberText(a)),
        AdvToken.blank,
        AdvToken(AdvKind.text, language.numberText(b)),
      ]),
      choices: [for (final s in ['<', '=', '>']) AdvChoice(AdvToken(AdvKind.symbol, s), '')],
      answerId: AdvToken(AdvKind.symbol, answer).id,
      spokenAnswer: '${language.numberWord(a)} … ${language.numberWord(b)}',
    );
  }

  // MARK: Missing Letter: e f _ h

  String _letter(int i) {
    final s = language.alphabetDisplay[i];
    return language.hasLetterCase ? s.toLowerCase() : s;
  }

  AdvQuestion? _missingLetter() {
    final total = language.alphabetDisplay.length;
    const length = 4;
    if (total < length + 2) return null;
    // age 3: start of the alphabet, blank at the end; age 4: first two thirds; age 5: anywhere
    final span = level <= 3
        ? math.min(total, 10)
        : (level == 4 ? math.max(length + 2, total * 2 ~/ 3) : total);
    final start = _between(0, span - length);
    final blank = level <= 3 ? length - 1 : _r.nextInt(length);
    final answerIndex = start + blank;

    final options = <int>{answerIndex};
    final near = [answerIndex - 2, answerIndex + 2, answerIndex - 3, answerIndex + 3, answerIndex + 4, answerIndex - 4]
        .where((i) => i >= 0 && i < total && (i < start || i >= start + length))
        .toList()
      ..shuffle(_r);
    for (final i in near) {
      if (options.length >= 3) break;
      options.add(i);
    }
    while (options.length < 3) {
      options.add(_r.nextInt(total));
    }
    final list = options.toList()..shuffle(_r);

    return AdvQuestion(
      key: '$start|$blank',
      prompt: AdvPrompt.row(
        [for (var i = 0; i < length; i++) i == blank ? AdvToken.blank : AdvToken(AdvKind.text, _letter(start + i))],
        rightToLeft: _rightToLeft,
      ),
      choices: [
        for (final i in list)
          AdvChoice(AdvToken(AdvKind.text, _letter(i)),
              i < language.alphabetSpoken.length ? language.alphabetSpoken[i] : _letter(i)),
      ],
      answerId: AdvToken(AdvKind.text, _letter(answerIndex)).id,
      spokenAnswer: answerIndex < language.alphabetSpoken.length
          ? language.alphabetSpoken[answerIndex]
          : _letter(answerIndex),
    );
  }

  // MARK: Missing Letter in Words (English): f _ x

  AdvQuestion _missingWordLetter() {
    final pool = level <= 3 ? words3 : (level == 4 ? [...words3, ...words4] : words4);
    final word = _pick(pool);
    final letters = word.split('');
    final blank = _r.nextInt(letters.length);
    final answer = letters[blank];
    final allWords = {...words3, ...words4};

    // wrong letters must not spell another word from the list
    final options = <String>[answer];
    final alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('')..shuffle(_r);
    for (final c in alphabet) {
      if (options.length >= 3) break;
      if (c == answer) continue;
      final test = List.of(letters)..[blank] = c;
      if (!allWords.contains(test.join())) options.add(c);
    }
    options.shuffle(_r);

    return AdvQuestion(
      key: '$word|$blank',
      prompt: AdvPrompt.row(
        [for (var i = 0; i < letters.length; i++) i == blank ? AdvToken.blank : AdvToken(AdvKind.text, letters[i])],
        tight: true,
      ),
      choices: [for (final c in options) AdvChoice(AdvToken(AdvKind.text, c), c)],
      answerId: AdvToken(AdvKind.text, answer).id,
      spokenAnswer: word,
    );
  }

  // MARK: Count the Pictures

  AdvQuestion? _count() {
    final lo = level >= 5 ? 5 : 1;
    final hi = math.min(level <= 3 ? 5 : (level == 4 ? 10 : 15), _maxNumber);
    final subjects = _subjects;
    if (hi < lo || subjects.isEmpty) return null;
    final subject = _pick(subjects);
    final n = _between(lo, hi);
    return AdvQuestion(
      key: '$subject|$n',
      prompt: AdvPrompt.count(subject, n),
      choices: _numberChoices(n, 1, hi),
      answerId: AdvToken(AdvKind.text, language.numberText(n)).id,
      spokenAnswer: language.numberWord(n),
    );
  }

  // MARK: Add & Take Away

  AdvQuestion? _addSubtract() {
    final top = level <= 3 ? 5 : math.min(10, _maxNumber);
    final plus = level < 5 || _r.nextBool();
    final subjects = _subjects;
    if (subjects.isEmpty) return null;
    final subject = _pick(subjects);
    late int a, b, answer;
    if (plus) {
      a = _between(1, top - 1);
      b = _between(1, top - a);
      answer = a + b;
    } else {
      a = _between(2, top);
      b = _between(1, a - 1);
      answer = a - b;
    }
    return AdvQuestion(
      key: '$a${plus ? '+' : '-'}$b',
      prompt: AdvPrompt.arithmetic(a, plus, b, subject, language.numberText(a), language.numberText(b)),
      choices: _numberChoices(answer, 0, top),
      answerId: AdvToken(AdvKind.text, language.numberText(answer)).id,
      spokenAnswer: language.numberWord(answer),
    );
  }

  // MARK: Odd One Out

  AdvQuestion? _oddOneOut() {
    final byCategory = <String, List<String>>{};
    KidsGamePictures.bySubject.forEach((subject, page) {
      byCategory.putIfAbsent(page.category, () => []).add(subject);
    });
    final mains = byCategory.keys.where((c) => byCategory[c]!.length >= 3).toList();
    if (mains.isEmpty || byCategory.length < 2) return null;
    final main = _pick(mains);
    final others = byCategory.keys.where((c) => c != main).toList();
    final odd = _pick(byCategory[_pick(others)]!);
    final three = (List.of(byCategory[main]!)..shuffle(_r)).take(3).toList();
    final all = [...three, odd]..shuffle(_r);
    final sortedThree = List.of(three)..sort();

    return AdvQuestion(
      key: '${sortedThree.join(',')}|$odd',
      prompt: const AdvPrompt.findOdd(),
      choices: [for (final s in all) AdvChoice(AdvToken(AdvKind.picture, s), _title(s))],
      answerId: AdvToken(AdvKind.picture, odd).id,
      spokenAnswer: _title(odd),
    );
  }

  // MARK: What Comes Next?  red blue red blue _

  AdvQuestion? _pattern() {
    // age 3: two colors AB; age 4: AB or AAB/ABB with colors or pictures; age 5: adds ABC
    final shapes = level <= 3
        ? [
            [0, 1]
          ]
        : (level == 4
            ? [
                [0, 1],
                [0, 0, 1],
                [0, 1, 1]
              ]
            : [
                [0, 1, 2],
                [0, 0, 1],
                [0, 1, 1],
                [0, 1, 2, 2]
              ]);
    final unit = _pick(shapes);
    final kinds = unit.reduce(math.max) + 1;
    final usePictures = level >= 4 && _r.nextBool();

    final List<AdvToken> pool;
    if (usePictures) {
      pool = (List.of(_subjects)..shuffle(_r)).take(kinds + 1).map((s) => AdvToken(AdvKind.picture, s)).toList();
    } else {
      pool = (colorHex.keys.toList()..shuffle(_r)).take(kinds + 1).map((c) => AdvToken(AdvKind.color, c)).toList();
    }
    if (pool.length < kinds + 1) return null;
    final items = pool.take(kinds).toList();
    final extra = pool[kinds];

    final length = math.max(5, unit.length * 2 + 1);
    final sequence = List.generate(length + 1, (i) => items[unit[i % unit.length]]);
    final answer = sequence[length];
    final shown = [...sequence.take(length), AdvToken.blank];

    final wrong = <AdvToken>{...items, extra}..remove(answer);
    final options = [...(wrong.toList()..shuffle(_r)).take(2), answer]..shuffle(_r);

    String spoken(AdvToken t) =>
        t.kind == AdvKind.picture ? _title(t.value) : language.colorWord(t.value);

    return AdvQuestion(
      key: shown.map((t) => t.id).join(','),
      prompt: AdvPrompt.row(shown),
      choices: [for (final t in options) AdvChoice(t, spoken(t))],
      answerId: answer.id,
      spokenAnswer: spoken(answer),
    );
  }
}
