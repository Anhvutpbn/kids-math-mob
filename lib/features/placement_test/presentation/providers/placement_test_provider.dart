import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/placement_test_api.dart';
import '../../models/placement_models.dart';

class PlacementTestState {
  final List<PlacementQuestion> questions;
  final int currentIndex;
  final List<PlacementAnswer> answers;
  final bool isSubmitting;
  final bool isDone;
  final DateTime? questionStartTime;

  const PlacementTestState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.isSubmitting = false,
    this.isDone = false,
    this.questionStartTime,
  });

  PlacementQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  double get progress =>
      questions.isEmpty ? 0 : currentIndex / questions.length;

  PlacementTestState copyWith({
    List<PlacementQuestion>? questions,
    int? currentIndex,
    List<PlacementAnswer>? answers,
    bool? isSubmitting,
    bool? isDone,
    DateTime? questionStartTime,
  }) =>
      PlacementTestState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isDone: isDone ?? this.isDone,
        questionStartTime: questionStartTime ?? this.questionStartTime,
      );
}

class PlacementTestNotifier extends AsyncNotifier<PlacementTestState> {
  @override
  Future<PlacementTestState> build() async {
    final questions = await ref.read(placementTestApiProvider).getQuestions();
    return PlacementTestState(
      questions: questions,
      questionStartTime: DateTime.now(),
    );
  }

  void answer(String answer) {
    final current = state.valueOrNull;
    if (current == null || current.currentQuestion == null) return;

    final timeSpent = DateTime.now()
        .difference(current.questionStartTime ?? DateTime.now())
        .inMilliseconds;

    final newAnswer = PlacementAnswer(
      questionId: current.currentQuestion!.id,
      answer: answer,
      timeSpentMs: timeSpent,
    );
    final newAnswers = [...current.answers, newAnswer];
    final nextIndex = current.currentIndex + 1;
    final isDone = nextIndex >= current.questions.length;

    state = AsyncData(current.copyWith(
      answers: newAnswers,
      currentIndex: nextIndex,
      isDone: isDone,
      questionStartTime: DateTime.now(),
    ));
  }

  Future<void> submit() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      await ref.read(placementTestApiProvider).submit(current.answers);
    } finally {
      state = AsyncData(current.copyWith(isSubmitting: false));
    }
  }
}

final placementTestProvider =
    AsyncNotifierProvider<PlacementTestNotifier, PlacementTestState>(
  PlacementTestNotifier.new,
);
