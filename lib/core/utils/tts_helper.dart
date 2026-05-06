import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init({String language = 'vi-VN'}) async {
    if (_initialized) return;
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(0.45);  // slower for kids
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
    _initialized = true;
  }

  Future<void> speak(String text, {required bool muted, String language = 'vi-VN'}) async {
    if (muted) return;
    try {
      await _tts.stop();
      await _tts.setLanguage(language);
      await _tts.speak(text);
    } catch (_) {
      // TTS errors (e.g. web voices not loaded yet) are non-fatal
    }
  }

  Future<void> stop() => _tts.stop();

  void dispose() => _tts.stop();
}

final ttsHelperProvider = Provider<TtsHelper>((ref) {
  final helper = TtsHelper();
  helper.init();
  ref.onDispose(helper.dispose);
  return helper;
});
