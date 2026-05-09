import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _muteKey = 'audio_muted';

class AudioHelper {
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _levelUpPlayer = AudioPlayer();
  bool _muted = false;

  // Cooldown: set synchronously before first await → race-condition safe in Dart event loop
  int _correctLastMs = 0;
  int _wrongLastMs = 0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_muteKey) ?? false;
  }

  bool get isMuted => _muted;

  Future<void> toggleMute() async {
    _muted = !_muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteKey, _muted);
  }

  Future<void> playCorrect() async {
    if (_muted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _correctLastMs < 500) return;
    _correctLastMs = now;
    await _safePlay(_correctPlayer, 'audio/correct.mp3');
  }

  Future<void> playWrong() async {
    if (_muted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _wrongLastMs < 600) return;
    _wrongLastMs = now;
    await _safePlay(_wrongPlayer, 'audio/wrong.mp3');
  }

  Future<void> playLevelUp() => _muted ? Future.value() : _safePlay(_levelUpPlayer, 'audio/levelup.mp3');

  // player.play(AssetSource) luôn dừng playback hiện tại và bắt đầu lại từ đầu,
  // hoạt động đúng ở mọi trạng thái player (stopped, completed, playing, paused).
  Future<void> _safePlay(AudioPlayer player, String asset) async {
    try {
      await player.play(AssetSource(asset));
    } catch (_) {}
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
