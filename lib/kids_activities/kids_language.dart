// The ONLY file that connects these activities to the rest of the app.
//
// 1. Build a [KidsLanguage] from the app's own language data
//    (number words and color names per language).
// 2. Point [KidsGameServices.speak] / [KidsGameServices.stopSpeaking]
//    at the app's text-to-speech helper, once, e.g. in main():
//
//      KidsGameServices.speak = (text, code) => MyTts.instance.speak(text, code);
//      KidsGameServices.stopSpeaking = () => MyTts.instance.stop();
//
// Until that is done everything still runs, in English and silently.

typedef KidsSpeakFunction = Future<void> Function(String text, String languageCode);

class KidsGameServices {
  static KidsSpeakFunction speak = (text, languageCode) async {};
  static Future<void> Function() stopSpeaking = () async {};
}

class KidsLanguage {
  /// App language id, e.g. 'en', 'hi'.
  final String id;

  /// Text-to-speech code, e.g. 'en-US', 'hi-IN'.
  final String speechCode;

  /// Digit as written in this language, index = number (index 0 is zero).
  final List<String> numberDisplay;

  /// Number word to speak, index = number.
  final List<String> numberSpoken;

  /// Color name as written, keyed by color key ('red', 'green' ...).
  final Map<String, String> colorDisplay;

  /// Color name to speak, keyed by color key.
  final Map<String, String> colorSpoken;

  /// Letters in alphabet order, as written and as spoken.
  final List<String> alphabetDisplay;
  final List<String> alphabetSpoken;

  /// True for scripts with capital and small letters (English, Spanish...).
  final bool hasLetterCase;

  const KidsLanguage({
    required this.id,
    required this.speechCode,
    required this.numberDisplay,
    required this.numberSpoken,
    required this.colorDisplay,
    required this.colorSpoken,
    this.alphabetDisplay = const [],
    this.alphabetSpoken = const [],
    this.hasLetterCase = false,
  });

  String numberText(int n) => n >= 0 && n < numberDisplay.length ? numberDisplay[n] : '$n';

  String numberWord(int n) => n >= 0 && n < numberSpoken.length ? numberSpoken[n] : '$n';

  String colorText(String key) {
    final word = colorDisplay[key];
    if (word != null && word.isNotEmpty) return word;
    return key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
  }

  String colorWord(String key) => colorSpoken[key] ?? colorText(key);

  Future<void> speak(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return KidsGameServices.speak(trimmed, speechCode);
  }

  /// Fallback used until the app's data is wired in.
  static const english = KidsLanguage(
    id: 'en',
    speechCode: 'en-US',
    numberDisplay: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
    numberSpoken: ['Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'],
    colorDisplay: {
      'red': 'Red', 'orange': 'Orange', 'yellow': 'Yellow', 'green': 'Green', 'blue': 'Blue',
      'purple': 'Purple', 'pink': 'Pink', 'brown': 'Brown', 'black': 'Black',
    },
    colorSpoken: {
      'red': 'Red', 'orange': 'Orange', 'yellow': 'Yellow', 'green': 'Green', 'blue': 'Blue',
      'purple': 'Purple', 'pink': 'Pink', 'brown': 'Brown', 'black': 'Black',
    },
    alphabetDisplay: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    alphabetSpoken: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    hasLetterCase: true,
  );
}
