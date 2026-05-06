import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_api.dart';
import '../../models/dashboard_models.dart';

class DashboardState {
  final DashboardSummary? summary;
  final List<DailyXp> weeklyProgress;
  final List<WeakSkill> weakSkills;
  final List<SessionHistoryItem> sessionHistory;
  final AiInsight? insight;
  final bool isLoading;
  final String? error;
  final String historyRange;

  const DashboardState({
    this.summary,
    this.weeklyProgress = const [],
    this.weakSkills = const [],
    this.sessionHistory = const [],
    this.insight,
    this.isLoading = false,
    this.error,
    this.historyRange = '30d',
  });

  DashboardState copyWith({
    DashboardSummary? summary,
    List<DailyXp>? weeklyProgress,
    List<WeakSkill>? weakSkills,
    List<SessionHistoryItem>? sessionHistory,
    AiInsight? insight,
    bool? isLoading,
    String? error,
    String? historyRange,
  }) =>
      DashboardState(
        summary: summary ?? this.summary,
        weeklyProgress: weeklyProgress ?? this.weeklyProgress,
        weakSkills: weakSkills ?? this.weakSkills,
        sessionHistory: sessionHistory ?? this.sessionHistory,
        insight: insight ?? this.insight,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        historyRange: historyRange ?? this.historyRange,
      );
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(loadAll);
    return const DashboardState(isLoading: true);
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    final api = ref.read(dashboardApiProvider);

    final results = await Future.wait([
      api.getSummary().catchError((_) => const DashboardSummary()),
      api.getWeeklyProgress().catchError((_) => <DailyXp>[]),
      api.getWeakAreas().catchError((_) => <WeakSkill>[]),
      api.getSessionHistory(range: state.historyRange).catchError((_) => <SessionHistoryItem>[]),
      api.getAiInsight().catchError((_) => const AiInsight(summary: '', tips: [])),
    ]);

    final weekly = results[1] as List<DailyXp>;
    final avgAcc = weekly.isNotEmpty
        ? (weekly.fold<int>(0, (s, d) => s + d.accuracy) / weekly.length).round()
        : 0;
    final rawSummary = results[0] as DashboardSummary;
    state = state.copyWith(
      summary: rawSummary.copyWith(avgAccuracyThisWeek: avgAcc),
      weeklyProgress: weekly,
      weakSkills: results[2] as List<WeakSkill>,
      sessionHistory: results[3] as List<SessionHistoryItem>,
      insight: results[4] as AiInsight,
      isLoading: false,
    );
  }

  Future<void> changeHistoryRange(String range) async {
    state = state.copyWith(historyRange: range, isLoading: true);
    try {
      final history = await ref.read(dashboardApiProvider).getSessionHistory(range: range);
      state = state.copyWith(sessionHistory: history, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
