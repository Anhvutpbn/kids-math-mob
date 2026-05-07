import 'package:flutter/material.dart';

// ─── Level config (local constants, mirrors API) ────────────────────────────

class MemoryGameLevelConfig {
  final int level;
  final int tier;
  final int numBoxes;
  final int displayTimeMs;
  final int mistakesAllowed;

  const MemoryGameLevelConfig({
    required this.level,
    required this.tier,
    required this.numBoxes,
    required this.displayTimeMs,
    required this.mistakesAllowed,
  });
}

const List<MemoryGameLevelConfig> kMemoryGameLevels = [
  MemoryGameLevelConfig(level: 1,  tier: 1, numBoxes: 4,  displayTimeMs: 5000,  mistakesAllowed: 1),
  MemoryGameLevelConfig(level: 2,  tier: 1, numBoxes: 4,  displayTimeMs: 4000,  mistakesAllowed: 1),
  MemoryGameLevelConfig(level: 3,  tier: 1, numBoxes: 4,  displayTimeMs: 3000,  mistakesAllowed: 1),
  MemoryGameLevelConfig(level: 4,  tier: 1, numBoxes: 4,  displayTimeMs: 2000,  mistakesAllowed: 1),
  MemoryGameLevelConfig(level: 5,  tier: 2, numBoxes: 6,  displayTimeMs: 7000,  mistakesAllowed: 2),
  MemoryGameLevelConfig(level: 6,  tier: 2, numBoxes: 6,  displayTimeMs: 5000,  mistakesAllowed: 2),
  MemoryGameLevelConfig(level: 7,  tier: 2, numBoxes: 6,  displayTimeMs: 4000,  mistakesAllowed: 2),
  MemoryGameLevelConfig(level: 8,  tier: 2, numBoxes: 6,  displayTimeMs: 3000,  mistakesAllowed: 2),
  MemoryGameLevelConfig(level: 9,  tier: 3, numBoxes: 10, displayTimeMs: 8000,  mistakesAllowed: 3),
  MemoryGameLevelConfig(level: 10, tier: 3, numBoxes: 10, displayTimeMs: 6000,  mistakesAllowed: 3),
  MemoryGameLevelConfig(level: 11, tier: 3, numBoxes: 10, displayTimeMs: 4000,  mistakesAllowed: 3),
  MemoryGameLevelConfig(level: 12, tier: 4, numBoxes: 15, displayTimeMs: 10000, mistakesAllowed: 4),
  MemoryGameLevelConfig(level: 13, tier: 4, numBoxes: 15, displayTimeMs: 7000,  mistakesAllowed: 4),
  MemoryGameLevelConfig(level: 14, tier: 4, numBoxes: 15, displayTimeMs: 5000,  mistakesAllowed: 4),
  MemoryGameLevelConfig(level: 15, tier: 5, numBoxes: 20, displayTimeMs: 12000, mistakesAllowed: 5),
  MemoryGameLevelConfig(level: 16, tier: 5, numBoxes: 20, displayTimeMs: 8000,  mistakesAllowed: 5),
];

MemoryGameLevelConfig? levelConfig(int level) {
  try {
    return kMemoryGameLevels.firstWhere((l) => l.level == level);
  } catch (_) {
    return null;
  }
}

// ─── Progress (from API) ────────────────────────────────────────────────────

class MemoryGameProgress {
  final int maxLevelUnlocked;
  final List<int> tiersCompleted;

  const MemoryGameProgress({
    required this.maxLevelUnlocked,
    required this.tiersCompleted,
  });

  factory MemoryGameProgress.fromJson(Map<String, dynamic> json) {
    return MemoryGameProgress(
      maxLevelUnlocked: (json['maxLevelUnlocked'] as num?)?.toInt() ?? 1,
      tiersCompleted: (json['tiersCompleted'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );
  }

  bool isLevelUnlocked(int level) => level <= maxLevelUnlocked;
  bool isTierCompleted(int tier) => tiersCompleted.contains(tier);
}

// ─── Submit response (from API) ─────────────────────────────────────────────

class MemoryGameSubmitResult {
  final bool passed;
  final int level;
  final int tier;
  final int maxLevelUnlocked;
  final List<int> tiersCompleted;
  final List<dynamic> newBadges;

  const MemoryGameSubmitResult({
    required this.passed,
    required this.level,
    required this.tier,
    required this.maxLevelUnlocked,
    required this.tiersCompleted,
    required this.newBadges,
  });

  factory MemoryGameSubmitResult.fromJson(Map<String, dynamic> json) {
    return MemoryGameSubmitResult(
      passed: json['passed'] as bool? ?? false,
      level: (json['level'] as num?)?.toInt() ?? 1,
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      maxLevelUnlocked: (json['maxLevelUnlocked'] as num?)?.toInt() ?? 1,
      tiersCompleted: (json['tiersCompleted'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      newBadges: json['newBadges'] as List<dynamic>? ?? [],
    );
  }
}

// ─── Game state ─────────────────────────────────────────────────────────────

const List<Color> kBoxColors = [
  Color(0xFFE74C3C), Color(0xFF3498DB), Color(0xFF2ECC71), Color(0xFFF39C12),
  Color(0xFF9B59B6), Color(0xFF1ABC9C), Color(0xFFE91E63), Color(0xFF00BCD4),
  Color(0xFFFF5722), Color(0xFF607D8B), Color(0xFFCDDC39), Color(0xFF795548),
  Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFF9800), Color(0xFF9C27B0),
  Color(0xFF009688), Color(0xFFFF4081), Color(0xFF8BC34A), Color(0xFF03A9F4),
];

enum GamePhase { showing, memorizing, completed }

class MemoryBox {
  final int number;
  final Color color;
  final bool tapped;
  final bool isWrong;

  const MemoryBox({
    required this.number,
    required this.color,
    this.tapped = false,
    this.isWrong = false,
  });

  MemoryBox copyWith({bool? tapped, bool? isWrong}) => MemoryBox(
        number: number,
        color: color,
        tapped: tapped ?? this.tapped,
        isWrong: isWrong ?? this.isWrong,
      );
}

class MemoryGameState {
  final List<MemoryBox> boxes;
  final GamePhase phase;
  final int mistakesMade;
  final int nextExpected;
  final int mistakesAllowed;
  final bool passed;
  final int durationMs;
  final DateTime? startedAt;

  const MemoryGameState({
    required this.boxes,
    required this.phase,
    required this.mistakesMade,
    required this.nextExpected,
    required this.mistakesAllowed,
    required this.passed,
    required this.durationMs,
    this.startedAt,
  });

  factory MemoryGameState.initial() => const MemoryGameState(
        boxes: [],
        phase: GamePhase.showing,
        mistakesMade: 0,
        nextExpected: 1,
        mistakesAllowed: 1,
        passed: false,
        durationMs: 0,
      );

  MemoryGameState copyWith({
    List<MemoryBox>? boxes,
    GamePhase? phase,
    int? mistakesMade,
    int? nextExpected,
    bool? passed,
    int? durationMs,
    DateTime? startedAt,
  }) =>
      MemoryGameState(
        boxes: boxes ?? this.boxes,
        phase: phase ?? this.phase,
        mistakesMade: mistakesMade ?? this.mistakesMade,
        nextExpected: nextExpected ?? this.nextExpected,
        mistakesAllowed: mistakesAllowed,
        passed: passed ?? this.passed,
        durationMs: durationMs ?? this.durationMs,
        startedAt: startedAt ?? this.startedAt,
      );

  int get mistakesLeft => mistakesAllowed - mistakesMade;
}
