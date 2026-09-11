import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/content_dataset.dart';
import 'models.dart';

// ── Language provider ─────────────────────────────────────────────────

class LanguageProvider extends ChangeNotifier {
  AppLanguage _current = ContentDataset.languages.first;
  AppLanguage get currentLanguage => _current;

  void setLanguage(AppLanguage lang) {
    _current = lang;
    notifyListeners();
  }

  // Called by splash_screen.dart
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('language_id');
    if (savedId != null) {
      final found = ContentDataset.languages
          .where((l) => l.id == savedId)
          .firstOrNull;
      if (found != null) {
        _current = found;
        notifyListeners();
      }
    }
  }

  Future<void> saveLanguage(AppLanguage lang) async {
    _current = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_id', lang.id);
    notifyListeners();
  }

  List<TraceItem> itemsFor(Category category) =>
      ContentDataset.items(_current.id, category);
}

// ── TTS provider ──────────────────────────────────────────────────────

class TTSProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _muted = false;
  bool get isMuted => _muted;

  TTSProvider() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);
  }

  // Called by splash_screen.dart
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('tts_muted') ?? false;
    notifyListeners();
  }

  Future<void> speak(String text, String languageCode) async {
    if (_muted) return;
    await _tts.stop();
    await _tts.setLanguage(languageCode);
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();

  void toggleMute() {
    _muted = !_muted;
    if (_muted) _tts.stop();
    SharedPreferences.getInstance()
        .then((p) => p.setBool('tts_muted', _muted));
    notifyListeners();
  }
}

// ── Purchase provider ─────────────────────────────────────────────────

class PurchaseProvider extends ChangeNotifier {
  static const _key = 'is_unlocked';
  bool _unlocked = false;
  bool get isUnlocked => _unlocked;

  PurchaseProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _unlocked = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> unlock() async {
    _unlocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    notifyListeners();
  }

  Future<void> restore() async => unlock();
}

// ── Progress provider ─────────────────────────────────────────────────

class ProgressProvider extends ChangeNotifier {
  final Map<String, Set<String>> _completed = {};

  // Called by splash_screen.dart
  Future<void> loadProgress() async {
    // Progress is in-memory for now.
    // Persist to SharedPreferences here if needed in future.
    notifyListeners();
  }

  void markComplete(String langId, Category cat, String display) {
    final key = '${langId}_${cat.name}';
    _completed.putIfAbsent(key, () => {}).add(display);
    notifyListeners();
  }

  int completedCount(String langId, Category cat) {
    final key = '${langId}_${cat.name}';
    return _completed[key]?.length ?? 0;
  }
}