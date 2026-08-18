import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // for ProductDetails
import 'package:shared_preferences/shared_preferences.dart';

import 'data/content_dataset.dart';
import 'models.dart';
import 'purchase_service.dart';
import 'tts_service.dart';

// ---------------------------------------------------------------- Language

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = ContentDataset.languages.first;
  bool _isLoading = true;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;

  List<AppLanguage> get languages => ContentDataset.languages;

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language.id);
    } catch (_) {}
  }

  Future<void> loadSavedLanguage() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('selected_language') ?? 'en';
      _currentLanguage = ContentDataset.languageById(savedId);
    } catch (_) {
      _currentLanguage = ContentDataset.languages.first;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Content for the current language + category.
  List<TraceItem> itemsFor(Category category) =>
      ContentDataset.items(_currentLanguage.id, category);
}

// ---------------------------------------------------------------- Purchases

class PurchaseProvider extends ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();

  bool _isUnlocked = false;
  bool _isLoading = false;
  String? _error;
  ProductDetails? _product;

  bool get isUnlocked => _isUnlocked;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductDetails? get product => _product;
  String? get price => _product?.price;

  PurchaseProvider() {
    initialize();
  }

  Future<void> initialize() async {
    try {
      await _purchaseService.initialize();

      _purchaseService.setPurchaseCallback((unlocked) {
        _isUnlocked = unlocked;
        _isLoading = false;
        notifyListeners();
      });

      _isUnlocked = await _purchaseService.isUnlocked();
      notifyListeners();

      _product = await _purchaseService.fetchProduct();
      notifyListeners();

      // The cached entitlement lives in SharedPreferences, which an uninstall
      // wipes. Ask the store what this account already owns; anything owned
      // arrives on the purchase stream as PurchaseStatus.restored and flips
      // the flag via the callback above. Mirrors refreshEntitlement() on iOS.
      if (!_isUnlocked) {
        await _purchaseService.restorePurchases();
      }
    } catch (_) {
      _error = 'Failed to initialize purchases';
      notifyListeners();
    }
  }

  /// English is free; every other language needs the unlock.
  bool isLanguageAvailable(AppLanguage language) =>
      language.id == 'en' || _isUnlocked;

  Future<void> checkUnlockStatus() async {
    _isUnlocked = await _purchaseService.isUnlocked();
    notifyListeners();
  }

  Future<void> purchase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _purchaseService.purchaseProduct();
    } catch (e) {
      _error = 'Purchase failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _purchaseService.restorePurchases();
      await Future<void>.delayed(const Duration(seconds: 1));
      await checkUnlockStatus();
    } catch (e) {
      _error = 'Restore failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------- Progress

class ProgressProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_progress';

  final Map<String, Set<String>> _completed = <String, Set<String>>{};

  /// Key is "languageId|categoryName".
  String _key(String languageId, Category category) =>
      '$languageId|${category.name}';

  bool isCompleted(String languageId, Category category, String itemText) =>
      _completed[_key(languageId, category)]?.contains(itemText) ?? false;

  int completedCount(String languageId, Category category) =>
      _completed[_key(languageId, category)]?.length ?? 0;

  Future<void> toggleComplete(
      String languageId,
      Category category,
      String itemText,
      ) async {
    final set = _completed.putIfAbsent(_key(languageId, category), () => <String>{});
    if (!set.add(itemText)) set.remove(itemText);
    notifyListeners();
    await _save();
  }

  Future<void> markComplete(
      String languageId,
      Category category,
      String itemText,
      ) async {
    _completed
        .putIfAbsent(_key(languageId, category), () => <String>{})
        .add(itemText);
    notifyListeners();
    await _save();
  }

  Future<void> clearProgress() async {
    _completed.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _completed.map((k, v) => MapEntry(k, v.toList()));
      await prefs.setString(_prefsKey, jsonEncode(map));
    } catch (_) {}
  }

  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _completed
        ..clear()
        ..addAll(decoded.map((k, v) => MapEntry(
          k,
          (v as List<dynamic>).map((e) => e.toString()).toSet(),
        )));
    } catch (_) {
    } finally {
      notifyListeners();
    }
  }
}

// ---------------------------------------------------------------- TTS

class TTSProvider extends ChangeNotifier {
  static const String _mutedKey = 'tts_muted';

  final TTSService _ttsService = TTSService();
  bool _isSpeaking = false;
  bool _isMuted = false;

  bool get isSpeaking => _isSpeaking;
  bool get isMuted => _isMuted;

  /// Restores the saved mute preference. Called during startup.
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool(_mutedKey) ?? false;
    } catch (_) {
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    notifyListeners();

    if (_isMuted) await _ttsService.stop();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mutedKey, _isMuted);
    } catch (_) {}
  }

  Future<void> speak(String text, String languageCode) async {
    if (_isMuted) return;

    _isSpeaking = true;
    notifyListeners();
    try {
      await _ttsService.speak(text, languageCode);
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _ttsService.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}