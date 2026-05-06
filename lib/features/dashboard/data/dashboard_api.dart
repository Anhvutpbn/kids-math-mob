import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/dashboard_models.dart';

class DashboardApi {
  final Dio _dio;
  DashboardApi(this._dio);

  Future<DashboardSummary> getSummary() async {
    final res = await _dio.get(ApiEndpoints.dashboardSummary);
    final raw = Map<String, dynamic>.from(res.data['data'] as Map<String, dynamic>);
    // API returns "streak" but model field is "streakCurrent"
    raw['streakCurrent'] ??= raw['streak'] ?? 0;
    return DashboardSummary.fromJson(raw);
  }

  /// Returns sessions grouped by day for the weekly XP chart.
  Future<List<DailyXp>> getWeeklyProgress() async {
    final res = await _dio.get(
      ApiEndpoints.dashboardSessionHistory,
      queryParameters: {'days': 7},
    );
    final list = res.data['data'] as List? ?? [];

    // Group raw LearningSession documents by day
    final Map<String, _DayAccum> byDay = {};
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      final rawDate = (m['endedAt'] ?? m['createdAt'] ?? '') as String;
      if (rawDate.isEmpty) continue;
      final day = rawDate.substring(0, 10); // "YYYY-MM-DD"
      byDay.putIfAbsent(day, () => _DayAccum());
      byDay[day]!.xp += (m['xpEarned'] as num? ?? 0).toInt();
      byDay[day]!.correct += (m['correctCount'] as num? ?? 0).toInt();
      byDay[day]!.total += (m['totalQuestions'] as num? ?? 0).toInt();
    }

    return byDay.entries.map((e) {
      final acc = e.value;
      final accuracy = acc.total > 0 ? (acc.correct / acc.total * 100).round() : 0;
      return DailyXp(date: e.key, xp: acc.xp, accuracy: accuracy);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<WeakSkill>> getWeakAreas() async {
    final res = await _dio.get(ApiEndpoints.aiWeakAreas);
    final list = res.data['data'] as List? ?? [];
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
      // API returns masteryScore; model field is mastery
      m['mastery'] ??= m['masteryScore'] ?? 0;
      // API does not return skillNameVi; use skillId as fallback
      m['skillNameVi'] ??= m['skillId'] ?? '';
      return WeakSkill.fromJson(m);
    }).toList();
  }

  Future<List<SessionHistoryItem>> getSessionHistory({String range = '30d'}) async {
    final days = _parseDays(range);
    final res = await _dio.get(
      ApiEndpoints.dashboardSessionHistory,
      queryParameters: {'days': days},
    );
    final list = res.data['data'] as List? ?? [];
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
      m['id'] ??= m['_id']?.toString() ?? '';
      m['date'] ??= m['endedAt'] ?? m['createdAt'] ?? '';
      m['totalCount'] ??= m['totalQuestions'] ?? 0;
      m['durationSeconds'] ??= ((m['totalDurationMs'] as num? ?? 0) / 1000).round();
      return SessionHistoryItem.fromJson(m);
    }).toList();
  }

  Future<List<SessionQuestionDetail>> getSessionDetail(String sessionId) async {
    final res = await _dio.get(ApiEndpoints.sessionDetail(sessionId));
    final list = res.data['data'] as List? ?? [];
    return list
        .map((e) => SessionQuestionDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AiInsight> getAiInsight() async {
    final res = await _dio.get(ApiEndpoints.dashboardAiInsight);
    final raw = res.data['data'] as Map<String, dynamic>? ?? {};
    return _remapAiInsight(raw);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  AiInsight _remapAiInsight(Map<String, dynamic> raw) {
    final accuracy = ((raw['overallAccuracy'] as num? ?? 0) * 100).round();
    final weakest = (raw['weakestSkills'] as List? ?? [])
        .map((e) => (e as Map)['skillId']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final focus = (raw['recommendedFocus'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    final summary = weakest.isEmpty
        ? 'Độ chính xác tổng thể: $accuracy%'
        : 'Độ chính xác: $accuracy%. Kỹ năng cần chú ý: ${weakest.join(", ")}.';

    final tips = focus.map((s) => 'Luyện thêm kỹ năng $s').toList();

    return AiInsight(summary: summary, tips: tips);
  }

  int _parseDays(String range) {
    if (range == 'all') return 365;
    final match = RegExp(r'^(\d+)').firstMatch(range);
    return match != null ? int.parse(match.group(1)!) : 30;
  }
}

class _DayAccum {
  int xp = 0;
  int correct = 0;
  int total = 0;
}

final dashboardApiProvider = Provider<DashboardApi>(
  (ref) => DashboardApi(ref.watch(dioProvider)),
);
