import 'package:flutter/material.dart';

// ── Category ──────────────────────────────────────────────────────────

enum Category {
  alphabets,
  numbers,
  words,
  colors,
  shapes,
  lines,
  trafficSigns,
  xylophone,
  sounds,
  days,
  months,
}

extension CategoryInfo on Category {
  String get title {
    switch (this) {
      case Category.alphabets:    return 'Alphabets';
      case Category.numbers:      return 'Numbers';
      case Category.words:        return 'Words';
      case Category.colors:       return 'Colors';
      case Category.shapes:       return 'Shapes';
      case Category.days:         return 'Days';
      case Category.months:       return 'Months';
      case Category.trafficSigns: return 'Traffic Signs';
      case Category.sounds:       return 'Sounds';
      case Category.xylophone:    return 'Xylophone';
      case Category.lines:        return 'Lines';
    }
  }

  String localizedTitle(String languageId) {
    const map = <String, Map<Category, String>>{
      'hi': {
        Category.alphabets:    'वर्णमाला',
        Category.numbers:      'अंक',
        Category.words:        'शब्द',
        Category.colors:       'रंग',
        Category.shapes:       'आकृतियाँ',
        Category.days:         'सप्ताह के दिन',
        Category.months:       'महीने',
        Category.trafficSigns: 'यातायात संकेत',
        Category.sounds:       'ध्वनि',
        Category.xylophone: 'ज़ाइलोफ़ोन',
        Category.lines:        'रेखाएं',
      },
      'te': {
        Category.alphabets:    'అక్షరమాల',
        Category.numbers:      'అంకెలు',
        Category.words:        'పదాలు',
        Category.colors:       'రంగులు',
        Category.shapes:       'ఆకారాలు',
        Category.days:         'వారపు రోజులు',
        Category.months:       'నెలలు',
        Category.trafficSigns: 'ట్రాఫిక్ సంకేతాలు',
        Category.sounds:       'శబ్దాలు',
        Category.xylophone: 'జైలోఫోన్',
        Category.lines:        'గీతలు',
      },
      'ta': {
        Category.alphabets:    'எழுத்துக்கள்',
        Category.numbers:      'எண்கள்',
        Category.words:        'சொற்கள்',
        Category.colors:       'நிறங்கள்',
        Category.shapes:       'வடிவங்கள்',
        Category.days:         'வார நாட்கள்',
        Category.months:       'மாதங்கள்',
        Category.trafficSigns: 'போக்குவரத்து அடையாளங்கள்',
        Category.sounds:       'ஒலிகள்',
        Category.xylophone: 'சைலோஃபோன்',
        Category.lines:        'கோடுகள்',
      },
      'gu': {
        Category.alphabets:    'મૂળાક્ષરો',
        Category.numbers:      'અંકો',
        Category.words:        'શબ્દો',
        Category.colors:       'રંગો',
        Category.shapes:       'આકારો',
        Category.days:         'અઠવાડિયાના દિવસો',
        Category.months:       'મહિના',
        Category.trafficSigns: 'ટ્રાફિક સંકેતો',
        Category.sounds:       'અવાજો',
        Category.xylophone: 'ઝાયલોફોન',
        Category.lines:        'રેખાઓ',
      },
      'mr': {
        Category.alphabets:    'मुळाक्षरे',
        Category.numbers:      'अंक',
        Category.words:        'शब्द',
        Category.colors:       'रंग',
        Category.shapes:       'आकार',
        Category.days:         'आठवड्याचे दिवस',
        Category.months:       'महिने',
        Category.trafficSigns: 'वाहतूक चिन्हे',
        Category.sounds:       'आवाज',
        Category.xylophone: 'जायलोफोन',
        Category.lines:        'रेषा',
      },
      'ur': {
        Category.alphabets:    'حروفِ تہجی',
        Category.numbers:      'اعداد',
        Category.words:        'الفاظ',
        Category.colors:       'رنگ',
        Category.shapes:       'اشکال',
        Category.days:         'ہفتے کے دن',
        Category.months:       'مہینے',
        Category.trafficSigns: 'ٹریفک نشانات',
        Category.sounds:       'آوازیں',
        Category.xylophone: 'زائلوفون',
        Category.lines:        'لائنیں',
      },
      'ml': {
        Category.alphabets:    'അക്ഷരമാല',
        Category.numbers:      'അക്കങ്ങൾ',
        Category.words:        'വാക്കുകൾ',
        Category.colors:       'നിറങ്ങൾ',
        Category.shapes:       'ആകൃതികൾ',
        Category.days:         'ആഴ്ചദിവസങ്ങൾ',
        Category.months:       'മാസങ്ങൾ',
        Category.trafficSigns: 'ട്രാഫിക് ചിഹ്നങ്ങൾ',
        Category.sounds:       'ശബ്ദങ്ങൾ',
        Category.xylophone: 'സൈലോഫോൺ',
        Category.lines:        'വരകൾ',
      },
      'kn': {
        Category.alphabets:    'ಅಕ್ಷರಮಾಲೆ',
        Category.numbers:      'ಸಂಖ್ಯೆಗಳು',
        Category.words:        'ಪದಗಳು',
        Category.colors:       'ಬಣ್ಣಗಳು',
        Category.shapes:       'ಆಕಾರಗಳು',
        Category.days:         'ವಾರದ ದಿನಗಳು',
        Category.months:       'ತಿಂಗಳುಗಳು',
        Category.trafficSigns: 'ಸಂಚಾರ ಚಿಹ್ನೆಗಳು',
        Category.sounds:       'ಶಬ್ದಗಳು',
        Category.xylophone: 'ಕ್ಸಿಲೋಫೋನ್',
        Category.lines:        'ಗೆರೆಗಳು',
      },
      'es': {
        Category.alphabets:    'Alfabeto',
        Category.numbers:      'Números',
        Category.words:        'Palabras',
        Category.colors:       'Colores',
        Category.shapes:       'Formas',
        Category.days:         'Días de la semana',
        Category.months:       'Meses',
        Category.trafficSigns: 'Señales de tráfico',
        Category.sounds:       'Sonidos',
        Category.xylophone: 'Xilófono',
        Category.lines:        'Líneas',
      },
      'de': {
        Category.alphabets:    'Alphabet',
        Category.numbers:      'Zahlen',
        Category.words:        'Wörter',
        Category.colors:       'Farben',
        Category.shapes:       'Formen',
        Category.days:         'Wochentage',
        Category.months:       'Monate',
        Category.trafficSigns: 'Verkehrszeichen',
        Category.sounds:       'Töne',
        Category.xylophone: 'Xylophon',
        Category.lines:        'Linien',
      },
      'fr': {
        Category.alphabets:    'Alphabet',
        Category.numbers:      'Chiffres',
        Category.words:        'Mots',
        Category.colors:       'Couleurs',
        Category.shapes:       'Formes',
        Category.days:         'Jours de la semaine',
        Category.months:       'Mois',
        Category.trafficSigns: 'Panneaux de signalisation',
        Category.sounds:       'Sons',
        Category.xylophone: 'Xylophone',
        Category.lines:        'Lignes',
      },
      'pt': {
        Category.alphabets:    'Alfabeto',
        Category.numbers:      'Números',
        Category.words:        'Palavras',
        Category.colors:       'Cores',
        Category.shapes:       'Formas',
        Category.days:         'Dias da semana',
        Category.months:       'Meses',
        Category.trafficSigns: 'Sinais de trânsito',
        Category.sounds:       'Sons',
        Category.xylophone: 'Xilofone',
        Category.lines:        'Linhas',
      },
      'ja': {
        Category.alphabets:    'ひらがな',
        Category.numbers:      'すうじ',
        Category.words:        'ことば',
        Category.colors:       'いろ',
        Category.shapes:       'かたち',
        Category.days:         'ようび',
        Category.months:       'つき',
        Category.trafficSigns: 'こうつうひょうしき',
        Category.sounds:       'おと',
        Category.xylophone:    'もっきん',
        Category.lines:        'せん',
      },
      'zh': {
        Category.alphabets:    '汉字',
        Category.numbers:      '数字',
        Category.words:        '词语',
        Category.colors:       '颜色',
        Category.shapes:       '形状',
        Category.days:         '星期',
        Category.months:       '月份',
        Category.trafficSigns: '交通标志',
        Category.sounds:       '声音',
        Category.xylophone:    '木琴',
        Category.lines:        '线条',
      },
    };
    return map[languageId]?[this] ?? title;
  }

  // Returns emoji string — NOT IconData
  String get iconEmoji {
    switch (this) {
      case Category.alphabets:    return '🔤';
      case Category.numbers:      return '🔢';
      case Category.words:        return '📖';
      case Category.colors:       return '🎨';
      case Category.shapes:       return '⭐';
      case Category.days:         return '📅';
      case Category.months:       return '🗓️';
      case Category.trafficSigns: return '🚦';
      case Category.sounds:       return '🔊';
      case Category.xylophone:    return '🎵';
      case Category.lines:        return '〰️';
    }
  }

  // Keep old `icon` as IconData for backward compatibility
  // with any existing code that uses it
  IconData get icon {
    switch (this) {
      case Category.alphabets:    return Icons.abc;
      case Category.numbers:      return Icons.numbers;
      case Category.words:        return Icons.book;
      case Category.colors:       return Icons.palette;
      case Category.shapes:       return Icons.star_outline;
      case Category.days:         return Icons.calendar_today;
      case Category.months:       return Icons.calendar_month;
      case Category.trafficSigns: return Icons.traffic;
      case Category.sounds:       return Icons.volume_up;
      case Category.xylophone:    return Icons.music_note;
      case Category.lines:        return Icons.gesture;
    }
  }

  int get colorValue {
    switch (this) {
      case Category.alphabets:    return 0xFF3B6CF4; // Classic Blue
      case Category.numbers:      return 0xFFFF6B1A; // Bright Orange
      case Category.words:        return 0xFF2DA882; // Emerald Green
      case Category.colors:       return 0xFFE84545; // Coral Red
      case Category.shapes:       return 0xFF7C5CDB; // Deep Purple
      case Category.days:         return 0xFFD97706; // Amber / Golden
      case Category.months:       return 0xFFC2185B; // Rose / Berry
      case Category.trafficSigns: return 0xFFD91111; // Crimson Alert Red
      case Category.sounds:       return 0xFF0891B2; // Cyan / Ocean Blue
      case Category.xylophone:    return 0xFFEC4899; // Bright Pink (or 0xFF10B981 Lime/Mint)
      case Category.lines:        return 0xFF10B981; // Bright Mint / Lime
    }
  }

  Color get tint => Color(colorValue);
}

// ── AppLanguage ───────────────────────────────────────────────────────

class AppLanguage {
  final String id;
  final String name;
  final String nativeName;
  final String speechCode;
  final String glyph;
  final bool hasLetterCase;
  final bool isFree;

  const AppLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.speechCode,
    required this.glyph,
    this.hasLetterCase = false,
    this.isFree = false,
  });
}

// ── TraceItem ─────────────────────────────────────────────────────────

class TraceItem {
  final String display;
  final String spoken;
  final String? colorKey;
  final String? shapeKey;
  final String? imagePath;
  final List<String>? words;

  const TraceItem(
      this.display, {
        String? spoken,
        this.colorKey,
        this.shapeKey,
        this.imagePath,
        this.words,
      }) : spoken = spoken ?? display;
}

// ── Color map ─────────────────────────────────────────────────────────

const Map<String, int> itemColorMap = {
  'red':    0xFFFF0000,
  'orange': 0xFFFF8C00,
  'yellow': 0xFFF2C000,
  'green':  0xFF22A740,
  'blue':   0xFF007AFF,
  'purple': 0xFF9B59B6,
  'pink':   0xFFFF2D7D,
  'brown':  0xFF8B4513,
  'black':  0xFF000000,
};

// ── ItemColors ────────────────────────────────────────────────────────
// Defined here (single source of truth) — remove from drawing.dart
// and app_state.dart if duplicated there.

class ItemColors {
  static Color? get(String? key) {
    if (key == null) return null;
    final v = itemColorMap[key];
    return v != null ? Color(v) : null;
  }
}

// ── ShapeIcons ────────────────────────────────────────────────────────

class ShapeIcons {
  static IconData? get(String? shapeKey) {
    if (shapeKey == null) return null;
    if (shapeKey.startsWith('traffic_')) return Icons.directions_car;
    switch (shapeKey) {
      case 'circle':    return Icons.circle_outlined;
      case 'square':    return Icons.square_outlined;
      case 'triangle':  return Icons.change_history;
      case 'rectangle': return Icons.rectangle_outlined;
      case 'oval':      return Icons.egg_outlined;
      case 'star':      return Icons.star_outline;
      case 'heart':     return Icons.favorite_outline;
      case 'diamond':   return Icons.diamond_outlined;
      default:          return null;
    }
  }
}

// ── BackgroundPalette ─────────────────────────────────────────────────
// Defined here — remove from drawing.dart if duplicated there.

class BackgroundPalette {
  static const _colors = [
    Color(0xFFFFF9EC), Color(0xFFEBF6FF), Color(0xFFE8FFE8),
    Color(0xFFFFE8F0), Color(0xFFF0E8FF), Color(0xFFFFEEE0),
    Color(0xFFE0FFF8),
  ];
  static Color at(int index) => _colors[index.abs() % _colors.length];
}