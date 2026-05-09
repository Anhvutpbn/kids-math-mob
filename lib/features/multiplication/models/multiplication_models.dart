import 'dart:math';

enum MultiLevel { basic, medium, hard }

enum QuestionType { missingResult, missingLeft, missingRight }

class MultiLevelConfig {
  final MultiLevel level;
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int minTable;
  final int maxTable;
  final int questionCount;
  final int maxHearts;

  const MultiLevelConfig({
    required this.level,
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.minTable,
    required this.maxTable,
    required this.questionCount,
    required this.maxHearts,
  });
}

const List<MultiLevelConfig> multiplicationLevels = [
  MultiLevelConfig(
    level: MultiLevel.basic,
    id: 'basic',
    name: 'Cơ Bản',
    emoji: '⭐',
    description: 'Bảng nhân 1 → 5',
    minTable: 1,
    maxTable: 5,
    questionCount: 10,
    maxHearts: 3,
  ),
  MultiLevelConfig(
    level: MultiLevel.medium,
    id: 'medium',
    name: 'Trung Bình',
    emoji: '🌟',
    description: 'Bảng nhân 6 → 10',
    minTable: 6,
    maxTable: 10,
    questionCount: 15,
    maxHearts: 3,
  ),
  MultiLevelConfig(
    level: MultiLevel.hard,
    id: 'hard',
    name: 'Khó',
    emoji: '💫',
    description: 'Random 1×1 → 9×9',
    minTable: 1,
    maxTable: 9,
    questionCount: 20,
    maxHearts: 3,
  ),
];

class MultiplicationQuestion {
  final int a;
  final int b;
  final QuestionType type;

  const MultiplicationQuestion({
    required this.a,
    required this.b,
    required this.type,
  });

  int get result => a * b;

  int get answer {
    switch (type) {
      case QuestionType.missingResult:
        return result;
      case QuestionType.missingLeft:
        return a;
      case QuestionType.missingRight:
        return b;
    }
  }

  String get ttsText {
    switch (type) {
      case QuestionType.missingResult:
        return '$a nhân $b bằng bao nhiêu?';
      case QuestionType.missingLeft:
        return 'Bao nhiêu nhân $b bằng $result?';
      case QuestionType.missingRight:
        return '$a nhân bao nhiêu bằng $result?';
    }
  }
}

List<MultiplicationQuestion> generateQuestions(MultiLevelConfig config) {
  final random = Random();
  final questions = <MultiplicationQuestion>[];
  final usedPairs = <String>{};

  int attempts = 0;
  while (questions.length < config.questionCount && attempts < 300) {
    attempts++;
    int a;
    if (config.level == MultiLevel.hard) {
      a = 1 + random.nextInt(9);
    } else {
      a = config.minTable + random.nextInt(config.maxTable - config.minTable + 1);
    }
    final b = 1 + random.nextInt(9);
    final key = '$a×$b';

    // Allow duplicates only if pool is exhausted for the level
    final poolSize = config.level == MultiLevel.hard
        ? 81
        : (config.maxTable - config.minTable + 1) * 9;
    if (usedPairs.contains(key) && poolSize >= config.questionCount) continue;

    usedPairs.add(key);

    // 50% missingResult, 25% missingLeft, 25% missingRight
    final r = random.nextInt(4);
    final type = r == 0
        ? QuestionType.missingLeft
        : r == 1
            ? QuestionType.missingRight
            : QuestionType.missingResult;

    questions.add(MultiplicationQuestion(a: a, b: b, type: type));
  }

  return questions;
}

class MultiplicationProgress {
  final bool mediumUnlocked;
  final bool hardUnlocked;
  final int basicBestScore;
  final int mediumBestScore;
  final int hardBestScore;
  final int basicSessionCount;
  final int mediumSessionCount;
  final int hardSessionCount;

  const MultiplicationProgress({
    this.mediumUnlocked = false,
    this.hardUnlocked = false,
    this.basicBestScore = 0,
    this.mediumBestScore = 0,
    this.hardBestScore = 0,
    this.basicSessionCount = 0,
    this.mediumSessionCount = 0,
    this.hardSessionCount = 0,
  });

  factory MultiplicationProgress.fromJson(Map<String, dynamic> json) {
    return MultiplicationProgress(
      mediumUnlocked: json['mediumUnlocked'] as bool? ?? false,
      hardUnlocked: json['hardUnlocked'] as bool? ?? false,
      basicBestScore: json['basicBestScore'] as int? ?? 0,
      mediumBestScore: json['mediumBestScore'] as int? ?? 0,
      hardBestScore: json['hardBestScore'] as int? ?? 0,
      basicSessionCount: json['basicSessionCount'] as int? ?? 0,
      mediumSessionCount: json['mediumSessionCount'] as int? ?? 0,
      hardSessionCount: json['hardSessionCount'] as int? ?? 0,
    );
  }

  bool isUnlocked(MultiLevel level) {
    switch (level) {
      case MultiLevel.basic:
        return true;
      case MultiLevel.medium:
        return mediumUnlocked;
      case MultiLevel.hard:
        return hardUnlocked;
    }
  }

  int bestScore(MultiLevel level) {
    switch (level) {
      case MultiLevel.basic:
        return basicBestScore;
      case MultiLevel.medium:
        return mediumBestScore;
      case MultiLevel.hard:
        return hardBestScore;
    }
  }

  int sessionCount(MultiLevel level) {
    switch (level) {
      case MultiLevel.basic:
        return basicSessionCount;
      case MultiLevel.medium:
        return mediumSessionCount;
      case MultiLevel.hard:
        return hardSessionCount;
    }
  }
}

class MultiplicationHistoryItem {
  final String id;
  final String level;
  final int correctCount;
  final int totalCount;
  final int heartsLeft;
  final bool passed;
  final int score;
  final int durationMs;
  final DateTime completedAt;

  const MultiplicationHistoryItem({
    required this.id,
    required this.level,
    required this.correctCount,
    required this.totalCount,
    required this.heartsLeft,
    required this.passed,
    required this.score,
    required this.durationMs,
    required this.completedAt,
  });

  factory MultiplicationHistoryItem.fromJson(Map<String, dynamic> json) {
    return MultiplicationHistoryItem(
      id: json['id'] as String? ?? '',
      level: json['level'] as String? ?? 'basic',
      correctCount: json['correctCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      heartsLeft: json['heartsLeft'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      durationMs: json['durationMs'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get levelLabel {
    switch (level) {
      case 'medium':
        return 'Trung Bình';
      case 'hard':
        return 'Khó';
      default:
        return 'Cơ Bản';
    }
  }

  String get levelEmoji {
    switch (level) {
      case 'medium':
        return '🌟';
      case 'hard':
        return '💫';
      default:
        return '⭐';
    }
  }
}
