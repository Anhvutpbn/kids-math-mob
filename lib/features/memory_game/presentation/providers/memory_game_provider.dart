import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/memory_game_models.dart';
import '../../data/memory_game_api.dart';

class MemoryGameNotifier extends AutoDisposeNotifier<MemoryGameState> {
  DateTime? _memorizeStartedAt;

  @override
  MemoryGameState build() {
    return MemoryGameState.initial();
  }

  void startGame(MemoryGameLevelConfig config) {
    _memorizeStartedAt = null;
    final boxes = _generateBoxes(config.numBoxes);

    state = MemoryGameState(
      boxes: boxes,
      phase: GamePhase.showing,
      mistakesMade: 0,
      nextExpected: 1,
      mistakesAllowed: config.mistakesAllowed,
      passed: false,
      durationMs: 0,
    );
  }

  void startMemorizing() {
    if (state.phase != GamePhase.showing) return;
    _memorizeStartedAt = DateTime.now();
    state = state.copyWith(phase: GamePhase.memorizing);
  }

  void tapBox(int index) {
    if (state.phase != GamePhase.memorizing) return;
    final box = state.boxes[index];
    if (box.tapped || box.isWrong) return;

    if (box.number == state.nextExpected) {
      final newBoxes = List<MemoryBox>.from(state.boxes);
      newBoxes[index] = box.copyWith(tapped: true);

      if (state.nextExpected >= state.boxes.length) {
        _endGame(newBoxes, passed: true);
      } else {
        state = state.copyWith(boxes: newBoxes, nextExpected: state.nextExpected + 1);
      }
    } else {
      final newMistakes = state.mistakesMade + 1;
      final newBoxes = List<MemoryBox>.from(state.boxes);
      newBoxes[index] = box.copyWith(isWrong: true);
      state = state.copyWith(boxes: newBoxes, mistakesMade: newMistakes);

      if (newMistakes > state.mistakesAllowed) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (state.phase == GamePhase.memorizing) {
            _endGame(state.boxes, passed: false);
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (state.phase == GamePhase.memorizing) {
            final clearedBoxes = List<MemoryBox>.from(state.boxes);
            clearedBoxes[index] = clearedBoxes[index].copyWith(isWrong: false);
            state = state.copyWith(boxes: clearedBoxes);
          }
        });
      }
    }
  }

  Future<MemoryGameSubmitResult> submitResult(int level) async {
    final api = ref.read(memoryGameApiProvider);
    return api.submit(
      level: level,
      mistakesMade: state.mistakesMade,
      passed: state.passed,
      durationMs: state.durationMs,
    );
  }

  void _endGame(List<MemoryBox> finalBoxes, {required bool passed}) {
    final durationMs = _memorizeStartedAt != null
        ? DateTime.now().difference(_memorizeStartedAt!).inMilliseconds
        : 0;
    state = state.copyWith(
      boxes: finalBoxes,
      phase: GamePhase.completed,
      passed: passed,
      durationMs: durationMs,
    );
  }

  List<MemoryBox> _generateBoxes(int count) {
    final rng = Random();
    final colors = List<Color>.from(kBoxColors)..shuffle(rng);
    final numbers = List<int>.generate(count, (i) => i + 1)..shuffle(rng);
    return List.generate(count, (i) => MemoryBox(number: numbers[i], color: colors[i]));
  }
}

final memoryGameProvider =
    AutoDisposeNotifierProvider<MemoryGameNotifier, MemoryGameState>(
  MemoryGameNotifier.new,
);
