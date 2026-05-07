import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _muteKey = 'audio_muted';

class AudioHelper {
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _levelUpPlayer = AudioPlayer();
  bool _muted = false;
  bool _ready = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_muteKey) ?? false;
    // Pre-load so subsequent plays are instant
    try {
      await Future.wait([
        _correctPlayer.setSource(AssetSource('audio/correct.mp3')),
        _wrongPlayer.setSource(AssetSource('audio/wrong.mp3')),
        _levelUpPlayer.setSource(AssetSource('audio/levelup.mp3')),
      ]);
      _ready = true;
    } catch (_) {}
  }

  bool get isMuted => _muted;

  Future<void> toggleMute() async {
    _muted = !_muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteKey, _muted);
  }

  Future<void> playCorrect() => _play(_correctPlayer, 'audio/correct.mp3');
  Future<void> playWrong() => _play(_wrongPlayer, 'audio/wrong.mp3');
  Future<void> playLevelUp() => _play(_levelUpPlayer, 'audio/levelup.mp3');

  Future<void> _play(AudioPlayer player, String asset) async {
    if (_muted) return;
    try {
      if (_ready) {
        // Fast path: source already loaded, just seek & resume
        await player.seek(Duration.zero);
        await player.resume();
      } else {
        // Fallback: load and play from scratch (slightly slower but always works)
        await player.play(AssetSource(asset));
      }
    } catch (_) {
      // If fast path fails (e.g. player in bad state), fall back to play()
      try {
        await player.play(AssetSource(asset));
      } catch (_) {}
    }
  }

  void dispose() {
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
    _levelUpPlayer.dispose();
  }
}

final audioHelperProvider = Provider<AudioHelper>((ref) {
  final helper = AudioHelper();
  helper.init();
  ref.onDispose(helper.dispose);
  return helper;
});

/// Mute toggle notifier — keeps UI in sync.
class MuteNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_muteKey) ?? false;
    });
    return false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteKey, state);
    ref.read(audioHelperProvider)._muted = state;
  }
}

final muteProvider = NotifierProvider<MuteNotifier, bool>(MuteNotifier.new);
