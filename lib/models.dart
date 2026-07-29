import 'package:flutter/material.dart';

// ---------------------------------------------------------------- Language

class AppLanguage {
  final String id; // "en", "hi", "te", ...
  final String name; // "English", "Hindi"
  final String nativeName; // "हिन्दी"
  final String speechCode; // "hi-IN" — passed to flutter_tts
  final String glyph; // "अ"
  final bool hasLetterCase;

  const AppLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.speechCode,
    required this.glyph,
    required this.hasLetterCase,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppLanguage && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------- Category

enum Category {
  alphabets,
  numbers,
  words,
  days,
  colors,
  shapes,
  months,
}

extension CategoryX on Category {
  String get title {
    switch (this) {
      case Category.alphabets:
        return 'Alphabets';
      case Category.numbers:
        return 'Numbers';
      case Category.words:
        return 'Words';
      case Category.days:
        return 'Days';
      case Category.colors:
        return 'Colors';
      case Category.shapes:
        return 'Shapes';
      case Category.months:
        return 'Months';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.alphabets:
        return Icons.abc;
      case Category.numbers:
        return Icons.tag;
      case Category.words:
        return Icons.menu_book;
      case Category.days:
        return Icons.calendar_today;
      case Category.colors:
        return Icons.palette;
      case Category.shapes:
        return Icons.category;
      case Category.months:
        return Icons.date_range;
    }
  }

  Color get tint {
    switch (this) {
      case Category.alphabets:
        return Colors.blue;
      case Category.numbers:
        return Colors.orange;
      case Category.words:
        return Colors.green;
      case Category.days:
        return Colors.purple;
      case Category.colors:
        return Colors.pink;
      case Category.shapes:
        return Colors.teal;
      case Category.months:
        return Colors.indigo;
    }
  }

  /// Localized heading, falling back to the English [title].
  String localizedTitle(String languageId) {
    return _categoryTitles[languageId]?[this] ?? title;
  }
}

const Map<String, Map<Category, String>> _categoryTitles = {
  'hi': {
    Category.alphabets: 'वर्णमाला',
    Category.numbers: 'अंक',
    Category.words: 'शब्द',
    Category.days: 'दिन',
    Category.colors: 'रंग',
    Category.shapes: 'आकृतियाँ',
    Category.months: 'महीने',
  },
  'te': {
    Category.alphabets: 'అక్షరమాల',
    Category.numbers: 'అంకెలు',
    Category.words: 'పదాలు',
    Category.days: 'వారం',
    Category.colors: 'రంగులు',
    Category.shapes: 'ఆకారాలు',
    Category.months: 'నెలలు',
  },
  'ta': {
    Category.alphabets: 'எழுத்துக்கள்',
    Category.numbers: 'எண்கள்',
    Category.words: 'சொற்கள்',
    Category.days: 'நாட்கள்',
    Category.colors: 'நிறங்கள்',
    Category.shapes: 'வடிவங்கள்',
    Category.months: 'மாதங்கள்',
  },
};

// ---------------------------------------------------------------- TraceItem

class TraceItem {
  /// What is drawn on screen for tracing.
  final String display;

  /// What the speech synthesizer says (defaults to [display]).
  final String spoken;

  /// Key into [ItemColors] for the colors category.
  final String? colorKey;

  /// Key into ContentDataset.shapeKeys for the shapes category.
  final String? shapeKey;

  TraceItem(
      this.display, {
        String? spoken,
        this.colorKey,
        this.shapeKey,
      }) : spoken = spoken ?? display;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TraceItem && other.display == display);

  @override
  int get hashCode => display.hashCode;
}

// ---------------------------------------------------------------- Colors

class ItemColors {
  static const Map<String, Color> map = {
    'red': Colors.red,
    'orange': Colors.orange,
    'yellow': Color(0xFFF2BF00),
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'black': Colors.black,
  };

  static Color? get(String? key) => key == null ? null : map[key];
}

// ---------------------------------------------------------------- Shapes

class ShapeIcons {
  static const Map<String, IconData> map = {
    'circle': Icons.circle,
    'square': Icons.square,
    'triangle': Icons.change_history,
    'rectangle': Icons.rectangle,
    'oval': Icons.egg,
    'star': Icons.star,
    'heart': Icons.favorite,
    'diamond': Icons.diamond,
  };

  static IconData? get(String? key) => key == null ? null : map[key];
}