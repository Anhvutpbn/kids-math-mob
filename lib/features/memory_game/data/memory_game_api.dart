import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
