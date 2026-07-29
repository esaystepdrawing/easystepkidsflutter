import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  factory TTSService() => _instance;

  TTSService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (Platform.isIOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.duckOthers,
          ],
        );
      }

      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.38); // kid-friendly pace
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);

      _isInitialized = true;
    } catch (e) {
      // ignore: avoid_print
      print('TTS init error: $e');
    }
  }

  /// Speak [text] using [languageCode] such as "hi-IN" or "en-US".
  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;
    await init();

    try {
      final available = await _tts.isLanguageAvailable(languageCode);
      if (available == true) {
        await _tts.setLanguage(languageCode);
      } else {
        // Fall back to the base language, e.g. "hi" from "hi-IN".
        final base = languageCode.split('-').first;
        if (await _tts.isLanguageAvailable(base) == true) {
          await _tts.setLanguage(base);
        }
      }
      await _tts.speak(text);
    } catch (e) {
      // ignore: avoid_print
      print('TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {}
  }

  Future<List<String>> getLanguages() async {
    try {
      final langs = await _tts.getLanguages;
      if (langs is List) {
        return langs.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('TTS getLanguages error: $e');
    }
    return <String>[];
  }

  Future<bool> isLanguageAvailable(String languageCode) async {
    try {
      return await _tts.isLanguageAvailable(languageCode) == true;
    } catch (_) {
      return false;
    }
  }

  /// 0.0 – 1.0 (0.5 is roughly normal on Android)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (_) {}
  }

  /// 0.5 – 2.0
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();
  }
}