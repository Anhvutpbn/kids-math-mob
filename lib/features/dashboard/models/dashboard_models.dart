import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    @Default(0) int streakCurrent,
    @Default(0) int totalXp,
    @Default(0) int sessionsThisWeek,
    @Default(0) int avgAccuracyThisWeek,
    @Default(0) int totalSessionsAllTime,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

@freezed
class DailyXp with _$DailyXp {
  const factory DailyXp({
    required String date,
    @Default(0) int xp,
    @Default(0) int accuracy,
  }) = _DailyXp;

  factory DailyXp.fromJson(Map<String, dynamic> json) =>
      _$DailyXpFromJson(json);
}

@freezed
class WeakSkill with _$WeakSkill {
  const factory WeakSkill({
    required String skillId,
    required String skillNameVi,
    @Default(0) int mastery,
    String? suggestion,
  }) = _WeakSkill;

  factory WeakSkill.fromJson(Map<String, dynamic> json) =>
      _$WeakSkillFromJson(json);
}

@freezed
class SessionHistoryItem with _$SessionHistoryItem {
  const factory SessionHistoryItem({
    required String id,
    required String date,
    @Default(0) int stars,
    @Default(0) int xpEarned,
    @Default(0) int correctCount,
    @Default(0) int totalCount,
    @Default(0) int durationSeconds,
  }) = _SessionHistoryItem;

  factory SessionHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SessionHistoryItemFromJson(json);
}

@freezed
class SessionQuestionDetail with _$SessionQuestionDetail {
  const factory SessionQuestionDetail({
    required String questionId,
    required String questionVi,
    required String correctAnswer,
    required String submittedAnswer,
    required bool isCorrect,
    @Default(0) int timeSpentMs,
    @Default(1) int attemptNumber,
    String? errorType,
  }) = _SessionQuestionDetail;

  factory SessionQuestionDetail.fromJson(Map<String, dynamic> json) =>
      _$SessionQuestionDetailFromJson(json);
}

@freezed
class AiInsight with _$AiInsight {
  const factory AiInsight({
    required String summary,
    @Default([]) List<String> tips,
  }) = _AiInsight;

  factory AiInsight.fromJson(Map<String, dynamic> json) =>
      _$AiInsightFromJson(json);
}
