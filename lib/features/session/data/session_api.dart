import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/session_models.dart';

class SessionApi {
  final Dio _dio;
  SessionApi(this._dio);

  Future<Map<String, dynamic>> startSession() async {
    final res = await _dio.post(ApiEndpoints.sessionStart);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitQuestion({
    required String sessionId,
    required String questionId,
    required String skillId,
    required String answer,
    required bool isCorrect,
    required int timeSpentMs,
    required int attemptNumber,
    bool consecutiveErrors = false,
  }) async {
    final res = await _dio.post(ApiEndpoints.sessionSubmitQuestion, data: {
      'sessionId': sessionId,
      'questionId': questionId,
      'skillId': skillId,
      'userAnswer': answer,
      'isCorrect': isCorrect,
      'timeSpentMs': timeSpentMs,
      'attemptNumber': attemptNumber,
      'consecutiveErrors': consecutiveErrors,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endSession(String sessionId, {int totalDurationMs = 0}) async {
    final res = await _dio.post(ApiEndpoints.sessionEnd(sessionId), data: {
      'totalDurationMs': totalDurationMs,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>? ?? {};
    return {
      'sessionId': session['_id'] ?? sessionId,
      'totalQuestions': data['totalQuestions'] ?? session['totalQuestions'] ?? 0,
      'correctCount': data['correctCount'] ?? session['correctCount'] ?? 0,
      'stars': data['stars'] ?? session['stars'] ?? 0,
      'xpEarned': data['xpEarned'] ?? session['xpEarned'] ?? 0,
    };
  }

  Future<List<SessionQuestion>> getLessonQueue() async {
    final res = await _dio.get(ApiEndpoints.lessonQueueNext);
    final data = res.data['data'];
    if (data == null) return [];
    final questions = data['questions'] as List? ?? [];
    return questions
        .map((e) => SessionQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getLessonQueueRaw() async {
    final res = await _dio.get(ApiEndpoints.lessonQueueNext);
    return res.data['data'] as Map<String, dynamic>? ?? {};
  }

  Future<void> generateQueue() async {
    await _dio.post(ApiEndpoints.lessonQueueGenerate);
  }

  Future<void> triggerAiAnalyze(String sessionId) async {
    await _dio.post(ApiEndpoints.aiAnalyze, data: {'sessionId': sessionId});
  }
}

final sessionApiProvider = Provider<SessionApi>(
  (ref) => SessionApi(ref.watch(dioProvider)),
);
