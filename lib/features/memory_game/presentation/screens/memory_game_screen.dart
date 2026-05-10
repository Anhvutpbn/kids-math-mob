import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../data/memory_game_api.dart';
import '../../models/memory_game_models.dart';
import '../providers/memory_game_provider.dart';

class MemoryGameScreen extends ConsumerStatefulWidget {
  final MemoryGameLevelConfig config;
  const MemoryGameScreen({super.key, required this.config});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  bool _submitCalled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider.notifier).startGame(widget.config);
    });
  }

  Future<void> _handleCompleted(MemoryGameState game) async {
    if (_submitCalled) return;
    _submitCalled = true;

    if (game.passed && game.durationMs > 0) {
      saveMemoryGameBestTime(widget.config.level, game.durationMs);
    }

    MemoryGameSubmitResult? result;
    try {
      result = await ref.read(memoryGameProvider.notifier).submitResult(widget.config.level);
      ref.invalidate(memoryGameProgressProvider);
    } catch (_) {}

    if (!mounted) return;

    // Play sound + haptic exactly when popup appears
    if (game.passed) {
      HapticFeedback.lightImpact();
      ref.read(audioHelperProvider).playCorrect();
    } else {
      HapticFeedback.vibrate();
      ref.read(audioHelperProvider).playWrong();
    }

    _showResultDialog(game, result);
  }

  void _showResultDialog(MemoryGameState game, MemoryGameSubmitResult? result) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        game: game,
        config: widget.config,
        result: result,
        onPlayAgain: () {
          Navigator.of(context).pop();
          setState(() => _submitCalled = false);
          ref.read(memoryGameProvider.notifier).startGame(widget.config);
        },
        onBack: () {
          Navigator.of(context).pop();
          context.pop();
        },
        onNextLevel: result != null && game.passed && widget.config.level < 16
            ? () {
                Navigator.of(context).pop();
                final next = levelConfig(widget.config.level + 1);
                if (next != null) {
                  setState(() => _submitCalled = false);
                  ref.read(memoryGameProvider.notifier).startGame(next);
                  context.pushReplacement('/memory-game/play', extra: next);
                }
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(memoryGameProvider);

    ref.listen<MemoryGameState>(memoryGameProvider, (prev, next) {
      if (next.phase == GamePhase.completed && (prev?.phase != GamePhase.completed)) {
        _handleCompleted(next);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'LV ${widget.config.level}  ·  ${widget.config.numBoxes} ô',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          _MistakesIndicator(
            made: game.mistakesMade,
            allowed: game.mistakesAllowed,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Phase banner
          _PhaseBanner(game: game),

          const SizedBox(height: 16),

          // Box grid
          Expanded(
            child: Center(
              child: _BoxGrid(game: game),
            ),
          ),

          // Bottom status
          _BottomStatus(game: game),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Phase banner ────────────────────────────────────────────────────────────

class _PhaseBanner extends ConsumerWidget {
  final MemoryGameState game;
  const _PhaseBanner({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (game.phase == GamePhase.showing) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Text('👀', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nhìn và ghi nhớ vị trí các số!',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(memoryGameProvider.notifier).startMemorizing(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: const Text(
                'Bắt đầu! 🚀',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }

    if (game.phase == GamePhase.memorizing) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Text('🎯', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bấm theo thứ tự từ 1 → ...',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Box grid ────────────────────────────────────────────────────────────────

class _BoxGrid extends ConsumerWidget {
  final MemoryGameState game;
  const _BoxGrid({required this.game});

  int get _crossAxisCount {
    final n = game.boxes.length;
    if (n <= 4) return 2;
    if (n <= 6) return 3;
    if (n <= 15) return 5;
    return 4;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (game.boxes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: game.boxes.length,
        itemBuilder: (_, i) => _MemoryBoxWidget(
          box: game.boxes[i],
          index: i,
          phase: game.phase,
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(memoryGameProvider.notifier).tapBox(i);
          },
        ),
      ),
    );
  }
}

class _MemoryBoxWidget extends StatelessWidget {
  final MemoryBox box;
  final int index;
  final GamePhase phase;
  final VoidCallback onTap;

  const _MemoryBoxWidget({
    required this.box,
    required this.index,
    required this.phase,
    required this.onTap,
  });

  Color get _borderColor {
    if (box.isWrong) return Colors.redAccent;
    if (box.tapped) return Colors.greenAccent;
    return box.color;
  }

  Color get _bgColor {
    if (box.isWrong) return Colors.red.withOpacity(0.3);
    if (box.tapped) return Colors.green.withOpacity(0.3);
    return box.color.withOpacity(0.25);
  }

  @override
  Widget build(BuildContext context) {
    final showNumber = phase == GamePhase.showing;
    final canTap = phase == GamePhase.memorizing && !box.tapped;

    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: _borderColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: box.isWrong || box.tapped ? 3 : 1,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final size = constraints.maxHeight;
            return Center(
              child: showNumber
                  ? Text(
                      '${box.number}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: size * 0.65,
                        height: 1,
                      ),
                    )
                  : box.tapped
                      ? Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: size * 0.5)
                      : box.isWrong
                          ? Icon(Icons.close_rounded, color: Colors.redAccent, size: size * 0.5)
                          : null,
            );
          },
        ),
      ),
    );
  }
}

// ─── Mistakes indicator ───────────────────────────────────────────────────────

class _MistakesIndicator extends StatelessWidget {
  final int made;
  final int allowed;
  const _MistakesIndicator({required this.made, required this.allowed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(allowed, (i) {
        final used = i < made;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            used ? Icons.favorite_border_rounded : Icons.favorite_rounded,
            size: 20,
            color: used ? Colors.white30 : Colors.redAccent,
          ),
        );
      }),
    );
  }
}

// ─── Bottom status ────────────────────────────────────────────────────────────

class _BottomStatus extends StatelessWidget {
  final MemoryGameState game;
  const _BottomStatus({required this.game});

  @override
  Widget build(BuildContext context) {
    if (game.phase != GamePhase.memorizing) return const SizedBox.shrink();

    final remaining = game.boxes.length - game.nextExpected + 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Tiếp theo: ${game.nextExpected}  ·  Còn lại: $remaining',
              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result dialog ────────────────────────────────────────────────────────────

class _ResultDialog extends StatelessWidget {
  final MemoryGameState game;
  final MemoryGameLevelConfig config;
  final MemoryGameSubmitResult? result;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;
  final VoidCallback? onNextLevel;

  const _ResultDialog({
    required this.game,
    required this.config,
    required this.result,
    required this.onPlayAgain,
    required this.onBack,
    this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final passed = game.passed;
    final secs = (game.durationMs / 1000).toStringAsFixed(1);
    final newBadges = result?.newBadges ?? [];

    return Dialog(
      backgroundColor: const Color(0xFF1A1A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              passed ? '🎉' : '😢',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 12),
            Text(
              passed ? 'Xuất sắc!' : 'Chưa qua!',
              style: TextStyle(
                color: passed ? Colors.greenAccent : Colors.redAccent,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            // Time badge (shown on pass) or mistake count (on fail)
            if (passed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded, size: 18, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '$secs giây',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                'Sai ${game.mistakesMade}/${game.mistakesAllowed + 1} lần',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),

            // Unlocked next level banner
            if (passed && result != null && config.level < 16)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔓', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Mở khóa LV ${config.level + 1}!',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),

            // New badges
            if (newBadges.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: newBadges.map<Widget>((b) {
                  final name = b['nameVi'] as String? ?? '🏆';
                  return Chip(
                    backgroundColor: Colors.amber.withOpacity(0.2),
                    side: const BorderSide(color: Colors.amber),
                    label: Text(
                      '🏅 $name',
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28),

            // Buttons
            Column(
              children: [
                if (passed && onNextLevel != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNextLevel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('LV tiếp theo 🚀', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white60,
                          side: const BorderSide(color: Colors.white24),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Thoát'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPlayAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Chơi lại', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
