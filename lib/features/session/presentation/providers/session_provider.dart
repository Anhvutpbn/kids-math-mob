import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/session_api.dart';
import '../../models/session_models.dart';
import '../../../skill_map/presentation/providers/skill_map_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SessionNotifier extends AutoDisposeAsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final api = ref.read(sessionApiProvider);
    final focusSkillId = ref.read(sessionFocusSkillProvider);
    final focusDifficulty = ref.read(sessionFocusDifficultyProvider);

    List<SessionQuestion> questions;

    if (focusSkillId != null && focusDifficulty != null) {
      // Skill-focus mode: generate queue for specific skill + difficulty
      final sessionResult = await api.startSession();
      questions = await api.generateSkillFocusQueue(
        skillId: focusSkillId,
        difficulty: focusDifficulty,
      );
      if (questions.isEmpty) {
        throw Exception('Không có câu hỏi cho kỹ năng này. Vui lòng thử lại.');
      }
      final now = DateTime.now();
      return SessionState(
        sessionId: sessionResult['_id'] as String?,
        questions: questions,
        questionStartTime: now,
        sessionStartTime: now,
      );
    }

    // Adaptive mode: use AI-generated daily queue
    final results = await Future.wait([
      api.startSession(),
      api.getLessonQueue(),
    ]);

    final session = results[0] as Map<String, dynamic>;
    questions = results[1] as List<SessionQuestion>;

    if (questions.isEmpty) {
      await api.generateQueue();
      questions = await api.getLessonQueue();
    }

    if (questions.isEmpty) {
      throw Exception('Chưa có bài học nào được tạo. Hãy hoàn thành bài kiểm tra xếp lớp trước.');
    }

    final now = DateTime.now();
    return SessionState(
      sessionId: session['_id'] as String?,
      questions: questions,
      questionStartTime: now,
      sessionStartTime: now,
    );
  }


  Future<void> submitAnswer(String answer) async {
    final current = state.valueOrNull;
    if (current == null || current.currentQuestion == null) return;

    final q = current.currentQuestion!;
    final isCorrect = answer.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
    final timeSpent = DateTime.now()
        .difference(current.questionStartTime ?? DateTime.now())
        .inMilliseconds;
    final attempt = current.attemptCount + 1;

    // Optimistic UI: show feedback immediately
    final feedbackState = isCorrect
        ? AnswerFeedback.correct
        : attempt == 1
            ? AnswerFeedback.wrongHint
            : attempt == 2
                ? AnswerFeedback.wrongImage
                : AnswerFeedback.wrongAnswer;

    state = AsyncData(current.copyWith(
      feedback: feedbackState,
      attemptCount: attempt,
    ));

    // Submit to API
    try {
      final apiResult = await ref.read(sessionApiProvider).submitQuestion(
            sessionId: current.sessionId!,
            questionId: q.id,
            skillId: q.skillId,
            answer: answer,
            isCorrect: isCorrect,
            timeSpentMs: timeSpent,
            attemptNumber: attempt,
            consecutiveErrors: !isCorrect,
          );

      final inject = apiResult['injectTutorial'] as bool? ?? false;
      if (inject) {
        state = AsyncData(current.copyWith(
          injectTutorial: true,
          tutorialSkillId: q.skillId,
          feedback: feedbackState,
          attemptCount: attempt,
        ));
        return;
      }
    } catch (_) {}

    // Advance to next question after correct or max attempts
    if (isCorrect || attempt >= 3) {
      final newResults = [
        ...current.results,
        QuestionResult(
          questionId: q.id,
          answer: answer,
          isCorrect: isCorrect,
          timeSpentMs: timeSpent,
          attemptNumber: attempt,
        ),
      ];
      await Future.delayed(const Duration(milliseconds: 800));
      state = AsyncData(current.copyWith(
        currentIndex: current.currentIndex + 1,
        attemptCount: 0,
        feedback: AnswerFeedback.none,
        results: newResults,
        questionStartTime: DateTime.now(),
        injectTutorial: false,
      ));
    } else {
      state = AsyncData(state.valueOrNull!.copyWith(feedback: feedbackState));
      await Future.delayed(const Duration(milliseconds: 1800));
      if (state.valueOrNull?.feedback == feedbackState) {
        state = AsyncData(state.valueOrNull!.copyWith(feedback: AnswerFeedback.none));
      }
    }
  }

  void clearFeedback() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(feedback: AnswerFeedback.none));
  }

  void clearTutorial() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      injectTutorial: false,
      tutorialSkillId: null,
      currentIndex: current.currentIndex + 1,
      attemptCount: 0,
      feedback: AnswerFeedback.none,
      questionStartTime: DateTime.now(),
    ));
  }

  Future<SessionSummary?> endSession() async {
    final current = state.valueOrNull;
    if (current?.sessionId == null) return null;
    try {
      final totalDurationMs = current!.sessionStartTime != null
          ? DateTime.now().difference(current.sessionStartTime!).inMilliseconds
          : 0;
      final data = await ref.read(sessionApiProvider).endSession(
            current.sessionId!,
            totalDurationMs: totalDurationMs,
          );
      final summary = SessionSummary.fromJson(data);
      state = AsyncData(current.copyWith(summary: summary));
      // Trigger AI analysis in background, then refresh skill map
      ref.read(sessionApiProvider).triggerAiAnalyze(current.sessionId!).catchError((_) {});
      ref.invalidate(skillMapProvider);
      ref.invalidate(authStateProvider);
      return summary;
    } catch (_) {
      return null;
    }
  }
}

final sessionFocusSkillProvider = StateProvider<String?>((ref) => null);
final sessionFocusDifficultyProvider = StateProvider<int?>((ref) => null);

final sessionProvider = AsyncNotifierProvider.autoDispose<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
