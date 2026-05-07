import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/memory_game_api.dart';
import '../../models/memory_game_models.dart';

String _fmtMs(int ms) {
  if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';
  final m = ms ~/ 60000;
  final s = ((ms % 60000) / 1000).toStringAsFixed(0);
  return '${m}m ${s}s';
}

class MemoryGameLevelSelectScreen extends ConsumerWidget {
  const MemoryGameLevelSelectScreen({super.key});

  static const _tierColors = [
    Color(0xFFCD7F32), // bronze
    Color(0xFFC0C0C0), // silver
    Color(0xFFFFD700), // gold
    Color(0xFF00E5FF), // platinum
    Color(0xFFE040FB), // legendary
  ];

  static const _tierLabels = ['Đồng', 'Bạc', 'Vàng', 'Bạch Kim', 'Huyền Thoại'];
  static const _tierBoxes = [4, 6, 10, 15, 20];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(memoryGameProgressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '🧠 Siêu Trí Tuệ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
        ),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => _ErrorBody(onRetry: () => ref.invalidate(memoryGameProgressProvider)),
        data: (progress) {
          final bestTimes = ref.watch(bestTimesProvider).valueOrNull ?? {};
          return _LevelGrid(progress: progress, bestTimes: bestTimes);
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Không tải được dữ liệu', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final MemoryGameProgress progress;
  final Map<int, int> bestTimes;
  const _LevelGrid({required this.progress, required this.bestTimes});

  static const _tierColors = MemoryGameLevelSelectScreen._tierColors;
  static const _tierLabels = MemoryGameLevelSelectScreen._tierLabels;
  static const _tierBoxes  = MemoryGameLevelSelectScreen._tierBoxes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nhớ vị trí các số, sau đó bấm đúng thứ tự 1 → 2 → 3...',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // Tiers with levels
          for (int tier = 1; tier <= 5; tier++) ...[
            _TierSection(
              tier: tier,
              color: _tierColors[tier - 1],
              label: _tierLabels[tier - 1],
              boxCount: _tierBoxes[tier - 1],
              progress: progress,
              bestTimes: bestTimes,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _TierSection extends StatelessWidget {
  final int tier;
  final Color color;
  final String label;
  final int boxCount;
  final MemoryGameProgress progress;
  final Map<int, int> bestTimes;

  const _TierSection({
    required this.tier,
    required this.color,
    required this.label,
    required this.boxCount,
    required this.progress,
    required this.bestTimes,
  });

  List<MemoryGameLevelConfig> get _levels =>
      kMemoryGameLevels.where((l) => l.tier == tier).toList();

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress.isTierCompleted(tier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tier header
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '$tier',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Tier $tier — $label',
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              '$boxCount ô',
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 13),
            ),
            const Spacer(),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text('Hoàn thành', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Level chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _levels.map((cfg) => _LevelChip(
            config: cfg,
            color: color,
            unlocked: progress.isLevelUnlocked(cfg.level),
            bestTimeMs: bestTimes[cfg.level],
          )).toList(),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  final MemoryGameLevelConfig config;
  final Color color;
  final bool unlocked;
  final int? bestTimeMs;

  const _LevelChip({
    required this.config,
    required this.color,
    required this.unlocked,
    this.bestTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    final hasBest = bestTimeMs != null;
    return GestureDetector(
      onTap: unlocked
          ? () => context.push('/memory-game/play', extra: config)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: hasBest ? 84 : 72,
        decoration: BoxDecoration(
          color: unlocked ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? color : Colors.white12,
            width: unlocked ? 2 : 1,
          ),
        ),
        child: Center(
          child: unlocked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LV ${config.level}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    if (hasBest) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_rounded, size: 10, color: color.withOpacity(0.8)),
                          const SizedBox(width: 2),
                          Text(
                            _fmtMs(bestTimeMs!),
                            style: TextStyle(
                              color: color.withOpacity(0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )
              : const Icon(Icons.lock_rounded, color: Colors.white30, size: 22),
        ),
      ),
    );
  }
}
