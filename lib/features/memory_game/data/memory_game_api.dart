import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/memory_game_models.dart';

class MemoryGameApi {
  const MemoryGameApi(this._dio);
  final Dio _dio;

  Future<MemoryGameProgress> getProgress() async {
    final res = await _dio.get(ApiEndpoints.memoryGameProgress);
    return MemoryGameProgress.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<MemoryGameSubmitResult> submit({
    required int level,
    required int mistakesMade,
    required bool passed,
    required int durationMs,
  }) async {
    final res = await _dio.post(ApiEndpoints.memoryGameSubmit, data: {
      'level': level,
      'mistakesMade': mistakesMade,
      'passed': passed,
      'durationMs': durationMs,
    });
    return MemoryGameSubmitResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}

final memoryGameApiProvider = Provider<MemoryGameApi>(
  (ref) => MemoryGameApi(ref.watch(dioProvider)),
);

final memoryGameProgressProvider = FutureProvider.autoDispose<MemoryGameProgress>((ref) {
  return ref.read(memoryGameApiProvider).getProgress();
});

// ─── Local best-time storage ─────────────────────────────────────────────────

String _bestTimeKey(int level) => 'mg_best_ms_lv$level';

/// Saves [durationMs] for [level] only if it's a new personal best.
Future<void> saveMemoryGameBestTime(int level, int durationMs) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _bestTimeKey(level);
  final current = prefs.getInt(key);
  if (current == null || durationMs < current) {
    await prefs.setInt(key, durationMs);
  }
}

/// Returns a map of level → best time (ms) from local storage.
final bestTimesProvider = FutureProvider.autoDispose<Map<int, int>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return {
    for (var lv = 1; lv <= 16; lv++)
      if (prefs.getInt(_bestTimeKey(lv)) != null) lv: prefs.getInt(_bestTimeKey(lv))!,
  };
});
