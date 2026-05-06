import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _muteKey = 'audio_muted';

class AudioHelper {
  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;

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

  Future<void> playCorrect() => _play('audio/correct.mp3');
  Future<void> playWrong() => _play('audio/wrong.mp3');
  Future<void> playLevelUp() => _play('audio/levelup.mp3');

  Future<void> _play(String asset) async {
    if (_muted) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (_) {}
  }

  void dispose() => _player.dispose();
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
