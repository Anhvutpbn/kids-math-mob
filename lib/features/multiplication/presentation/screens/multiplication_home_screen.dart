import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/multiplication_models.dart';
import '../../data/multiplication_api.dart';

class MultiplicationHomeScreen extends ConsumerWidget {
  const MultiplicationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(multiplicationProgressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔢 Bảng Cửu Chương',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        Text(
                          'Chọn cấp độ để bắt đầu',
                          style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/multiplication/history'),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('Lịch sử'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFE65100)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Learn banner — học bảng cửu chương dạng slide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => context.push('/multiplication/learn'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF26C6DA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00897B).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Học Bảng Cửu Chương',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Xem từng bảng — 2 đến 9 — để ghi nhớ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Luyện tập',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Level cards
            Expanded(
              child: progressAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _LevelList(progress: const MultiplicationProgress()),
                data: (progress) => _LevelList(progress: progress),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelList extends StatelessWidget {
  final MultiplicationProgress progress;
  const _LevelList({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: multiplicationLevels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final config = multiplicationLevels[i];
        final unlocked = progress.isUnlocked(config.level);
        final bestScore = progress.bestScore(config.level);
        final sessionCount = progress.sessionCount(config.level);
        return _LevelCard(
          config: config,
          unlocked: unlocked,
          bestScore: bestScore,
          sessionCount: sessionCount,
          onTap: unlocked
              ? () => context.push('/multiplication/session', extra: config)
              : null,
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  final MultiLevelConfig config;
  final bool unlocked;
  final int bestScore;
  final int sessionCount;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.config,
    required this.unlocked,
    required this.bestScore,
    required this.sessionCount,
    this.onTap,
  });

  Color get _gradientStart {
    switch (config.level) {
      case MultiLevel.basic:
        return const Color(0xFFFF8F00);
      case MultiLevel.medium:
        return const Color(0xFF1565C0);
      case MultiLevel.hard:
        return const Color(0xFF6A1B9A);
    }
  }

  Color get _gradientEnd {
    switch (config.level) {
      case MultiLevel.basic:
        return const Color(0xFFFFB300);
      case MultiLevel.medium:
        return const Color(0xFF0288D1);
      case MultiLevel.hard:
        return const Color(0xFFAD1457);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: unlocked ? 1.0 : 0.65,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradientStart, _gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: _gradientStart.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Emoji badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unlocked ? config.emoji : '🔒',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoChip('${config.questionCount} câu'),
                        const SizedBox(width: 6),
                        _InfoChip('${'❤️' * config.maxHearts}'),
                        if (unlocked && sessionCount > 0) ...[
                          const SizedBox(width: 6),
                          _InfoChip('Tốt nhất: $bestScore%'),
                        ],
                        if (!unlocked) ...[
                          const SizedBox(width: 6),
                          _InfoChip(_unlockHint),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (unlocked)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String get _unlockHint {
    switch (config.level) {
      case MultiLevel.medium:
        return '🔒 Qua Cơ Bản';
      case MultiLevel.hard:
        return '🔒 Qua Trung Bình';
      default:
        return '';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
