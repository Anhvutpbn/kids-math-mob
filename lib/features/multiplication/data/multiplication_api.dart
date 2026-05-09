import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/multiplication_models.dart';

class MultiplicationApi {
  const MultiplicationApi(this._dio);
  final Dio _dio;

  Future<MultiplicationProgress> getProgress() async {
    final res = await _dio.get(ApiEndpoints.multiplicationProgress);
    final data = res.data['data'] as Map<String, dynamic>;
    return MultiplicationProgress.fromJson(data);
  }

  Future<Map<String, dynamic>> saveSession({
    required String level,
    required int correctCount,
    required int totalCount,
    required int heartsLeft,
    required bool passed,
    required int durationMs,
  }) async {
    final res = await _dio.post(ApiEndpoints.multiplicationSessionSave, data: {
      'level': level,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'heartsLeft': heartsLeft,
      'passed': passed,
      'durationMs': durationMs,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<MultiplicationHistoryItem>> getHistory({int limit = 20, int offset = 0}) async {
    final res = await _dio.get(
      ApiEndpoints.multiplicationHistory,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => MultiplicationHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final multiplicationApiProvider = Provider<MultiplicationApi>((ref) {
  return MultiplicationApi(ref.watch(dioProvider));
});

final multiplicationProgressProvider = FutureProvider.autoDispose<MultiplicationProgress>((ref) {
  return ref.read(multiplicationApiProvider).getProgress();
});

final multiplicationHistoryProvider =
    FutureProvider.autoDispose<List<MultiplicationHistoryItem>>((ref) {
  return ref.read(multiplicationApiProvider).getHistory();
});
