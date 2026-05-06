import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_models.freezed.dart';
part 'session_models.g.dart';

@freezed
class SessionQuestion with _$SessionQuestion {
  const factory SessionQuestion({
    required String id,
    required String skillId,
    required String type,
    required String questionVi,
    String? questionEn,
    @Default([]) List<String> options,
    required String correctAnswer,
    @Default(1) int difficulty,
    String? hintVi,
  }) = _SessionQuestion;

  factory SessionQuestion.fromJson(Map<String, dynamic> json) =>
      _$SessionQuestionFromJson(json);
}

@freezed
class QuestionResult with _$QuestionResult {
  const factory QuestionResult({
    required String questionId,
    required String answer,
    required bool isCorrect,
    required int timeSpentMs,
    @Default(1) int attemptNumber,
  }) = _QuestionResult;

  factory QuestionResult.fromJson(Map<String, dynamic> json) =>
      _$QuestionResultFromJson(json);
}

@freezed
class SessionSummary with _$SessionSummary {
  const factory SessionSummary({
    required String sessionId,
    required int totalQuestions,
    required int correctCount,
    required int stars,
    required int xpEarned,
  }) = _SessionSummary;

  factory SessionSummary.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryFromJson(json);
}

enum AnswerFeedback { none, correct, wrongHint, wrongImage, wrongAnswer }

class SessionState {
  final String? sessionId;
  final List<SessionQuestion> questions;
  final int currentIndex;
  final int attemptCount;
  final AnswerFeedback feedback;
  final List<QuestionResult> results;
  final bool isLoading;
  final SessionSummary? summary;
  final DateTime? questionStartTime;
  final DateTime? sessionStartTime;
  final bool injectTutorial;
  final String? tutorialSkillId;

  const SessionState({
    this.sessionId,
    this.questions = const [],
    this.currentIndex = 0,
    this.attemptCount = 0,
    this.feedback = AnswerFeedback.none,
    this.results = const [],
    this.isLoading = false,
    this.summary,
    this.questionStartTime,
    this.sessionStartTime,
    this.injectTutorial = false,
    this.tutorialSkillId,
  });

  SessionQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isDone => currentIndex >= questions.length;

  double get progress =>
      questions.isEmpty ? 0 : currentIndex / questions.length;

  SessionState copyWith({
    String? sessionId,
    List<SessionQuestion>? questions,
    int? currentIndex,
    int? attemptCount,
    AnswerFeedback? feedback,
    List<QuestionResult>? results,
    bool? isLoading,
    SessionSummary? summary,
    DateTime? questionStartTime,
    DateTime? sessionStartTime,
    bool? injectTutorial,
    String? tutorialSkillId,
  }) =>
      SessionState(
        sessionId: sessionId ?? this.sessionId,
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        attemptCount: attemptCount ?? this.attemptCount,
        feedback: feedback ?? this.feedback,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        summary: summary ?? this.summary,
        questionStartTime: questionStartTime ?? this.questionStartTime,
        sessionStartTime: sessionStartTime ?? this.sessionStartTime,
        injectTutorial: injectTutorial ?? this.injectTutorial,
        tutorialSkillId: tutorialSkillId ?? this.tutorialSkillId,
      );
}
