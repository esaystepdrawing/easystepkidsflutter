import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/content_dataset.dart';
import '../models.dart';
import 'kids_language.dart';

// Connects the activities to the app's own language data and speech.
// The two lines marked "CHECK" are the only guesses about existing code.

/// Number words and color names for [lang], taken from ContentDataset.
KidsLanguage kidsLanguageFor(AppLanguage lang) {
  // CHECK: if ContentDataset.items has a different signature, change these two lines.
  final List<TraceItem> numbers = ContentDataset.items(lang.id, Category.numbers);
  final List<TraceItem> colors = ContentDataset.items(lang.id, Category.colors);
  final List<TraceItem> letters = ContentDataset.items(lang.id, Category.alphabets);

  return KidsLanguage(
    id: lang.id,
    speechCode: lang.speechCode,
    numberDisplay: numbers.map((i) => i.display).toList(),
    numberSpoken: numbers.map((i) => i.spoken).toList(),
    colorDisplay: {
      for (final c in colors)
        if (c.colorKey != null) c.colorKey!: c.display,
    },
    colorSpoken: {
      for (final c in colors)
        if (c.colorKey != null) c.colorKey!: c.spoken,
    },
    alphabetDisplay: letters.map((i) => i.display).toList(),
    alphabetSpoken: letters.map((i) => i.spoken).toList(),
    hasLetterCase: lang.hasLetterCase,
  );
}

/// Routes the activities' speech through the app's TTSProvider.
/// Call before opening an activity (CategoryScreen does this).
void connectKidsSpeech(BuildContext context) {
  final tts = context.read<TTSProvider>();
  // CHECK: if TTSProvider's speak/stop take different arguments, change these two lines.
  KidsGameServices.speak = (text, languageCode) async {
    tts.speak(text, languageCode);
  };
  KidsGameServices.stopSpeaking = () async {
    tts.stop();
  };
}
