import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/multiplication_models.dart';
import '../../data/multiplication_api.dart';

enum MultiplicationPhase { answering, wrongFeedback, done }

class MultiplicationSessionState {
  final MultiLevelConfig config;
  final List<MultiplicationQuestion> questions;
  final int currentIndex;
  final int heartsLeft;
  final String input;
  final MultiplicationPhase phase;
  final bool isDone;
  final bool passed;
  final int correctCount;
  final bool wrongOnCurrent;
  final int startMs;

  const MultiplicationSessionState({
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.heartsLeft,
    required this.input,
    required this.phase,
    required this.isDone,
    required this.passed,
    required this.correctCount,
    required this.wrongOnCurrent,
    required this.startMs,
  });

  MultiplicationQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  double get progress =>
      questions.isEmpty ? 0.0 : currentIndex / questions.length;

  int get totalCount => questions.length;

  int get durationMs => DateTime.now().millisecondsSinceEpoch - startMs;

  MultiplicationSessionState copyWith({
    int? currentIndex,
    int? heartsLeft,
    String? input,
    MultiplicationPhase? phase,
    bool? isDone,
    bool? passed,
    int? correctCount,
    bool? wrongOnCurrent,
  }) {
    return MultiplicationSessionState(
      config: config,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      heartsLeft: heartsLeft ?? this.heartsLeft,
      input: input ?? this.input,
      phase: phase ?? this.phase,
      isDone: isDone ?? this.isDone,
      passed: passed ?? this.passed,
      correctCount: correctCount ?? this.correctCount,
      wrongOnCurrent: wrongOnCurrent ?? this.wrongOnCurrent,
      startMs: startMs,
    );
  }
}

class MultiplicationSessionNotifier
    extends AutoDisposeNotifier<MultiplicationSessionState?> {
  @override
  MultiplicationSessionState? build() => null;

  void startSession(MultiLevelConfig config) {
    final questions = generateQuestions(config);
    state = MultiplicationSessionState(
      config: config,
      questions: questions,
      currentIndex: 0,
      heartsLeft: config.maxHearts,
      input: '',
      phase: MultiplicationPhase.answering,
      isDone: false,
      passed: false,
      correctCount: 0,
      wrongOnCurrent: false,
      startMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void appendDigit(String digit) {
    final s = state;
    if (s == null || s.phase != MultiplicationPhase.answering || s.isDone) return;
    // Max 3 digits (largest answer is 10×9=90, but hard mode caps at 9×9=81)
    if (s.input.length >= 3) return;
    state = s.copyWith(input: s.input + digit);
  }

  void backspace() {
    final s = state;
    if (s == null || s.phase != MultiplicationPhase.answering || s.isDone) return;
    if (s.input.isEmpty) return;
    state = s.copyWith(input: s.input.substring(0, s.input.length - 1));
  }

  // Returns true if correct, false if wrong
  bool confirm() {
    final s = state;
    if (s == null || s.phase != MultiplicationPhase.answering || s.isDone) return false;
    final q = s.currentQuestion;
    if (q == null || s.input.isEmpty) return false;

    final userAnswer = int.tryParse(s.input);
    if (userAnswer == null) return false;

    if (userAnswer == q.answer) {
      _onCorrect(s, q);
      return true;
    } else {
      _onWrong(s);
      return false;
    }
  }

  void _onCorrect(MultiplicationSessionState s, MultiplicationQuestion q) {
    final newCorrect = s.correctCount + (s.wrongOnCurrent ? 0 : 1);
    final nextIndex = s.currentIndex + 1;
    final done = nextIndex >= s.questions.length;

    state = s.copyWith(
      currentIndex: nextIndex,
      input: '',
      correctCount: newCorrect,
      wrongOnCurrent: false,
      isDone: done,
      passed: done,
      phase: done ? MultiplicationPhase.done : MultiplicationPhase.answering,
    );
  }

  void _onWrong(MultiplicationSessionState s) {
    final newHearts = s.heartsLeft - 1;
    final fail = newHearts <= 0;

    state = s.copyWith(
      heartsLeft: newHearts,
      input: '',
      wrongOnCurrent: true,
      phase: fail ? MultiplicationPhase.done : MultiplicationPhase.wrongFeedback,
      isDone: fail,
      passed: false,
    );

    // Auto-reset wrong feedback after 600ms
    if (!fail) {
      Future.delayed(const Duration(milliseconds: 650), () {
        final cur = state;
        if (cur != null && cur.phase == MultiplicationPhase.wrongFeedback) {
          state = cur.copyWith(phase: MultiplicationPhase.answering);
        }
      });
    }
  }

  Future<Map<String, dynamic>?> saveResult() async {
    final s = state;
    if (s == null) return null;
    try {
      final result = await ref.read(multiplicationApiProvider).saveSession(
            level: s.config.id,
            correctCount: s.correctCount,
            totalCount: s.totalCount,
            heartsLeft: s.heartsLeft,
            passed: s.passed,
            durationMs: s.durationMs,
          );
      ref.invalidate(multiplicationProgressProvider);
      ref.invalidate(multiplicationHistoryProvider);
      return result;
    } catch (_) {
      return null;
    }
  }
}

final multiplicationSessionProvider = AutoDisposeNotifierProvider<
    MultiplicationSessionNotifier, MultiplicationSessionState?>(
  MultiplicationSessionNotifier.new,
);
