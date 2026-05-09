import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/multiplication_api.dart';
import '../../models/multiplication_models.dart';

class MultiplicationHistoryScreen extends ConsumerWidget {
  const MultiplicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(multiplicationHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      '📋 Lịch Sử Học',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(multiplicationHistoryProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Làm mới'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFE65100)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: historyAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('😢', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          'Không thể tải lịch sử',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'API chưa được khởi động lại sau khi cập nhật.\nChạy lại server rồi thử lại.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              ref.invalidate(multiplicationHistoryProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (history) {
                  if (history.isEmpty) {
                    return const _EmptyState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _HistoryCard(item: history[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch sử học',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bắt đầu học bảng cửu chương ngay nào!',
            style: TextStyle(color: Color(0xFF888888)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Học ngay 🚀', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MultiplicationHistoryItem item;
  const _HistoryCard({required this.item});

  Color get _levelColor {
    switch (item.level) {
      case 'medium':
        return const Color(0xFF1565C0);
      case 'hard':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFFFF8F00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = item.completedAt.toLocal();
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final secs = (item.durationMs / 1000).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _levelColor.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(item.levelEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.levelLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _levelColor,
                      ),
                    ),
                    const Spacer(),
                    _PassBadge(passed: item.passed),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniStat('✅', '${item.correctCount}/${item.totalCount}'),
                    const SizedBox(width: 12),
                    _MiniStat('📊', '${item.score}%'),
                    const SizedBox(width: 12),
                    _MiniStat('❤️', '${item.heartsLeft}/${3}'),
                    const SizedBox(width: 12),
                    _MiniStat('⏱', '${secs}s'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassBadge extends StatelessWidget {
  final bool passed;
  const _PassBadge({required this.passed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: passed
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: passed
              ? const Color(0xFF2E7D32).withOpacity(0.4)
              : Colors.redAccent.withOpacity(0.4),
        ),
      ),
      child: Text(
        passed ? '✅ Qua' : '❌ Thất bại',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: passed ? const Color(0xFF2E7D32) : Colors.redAccent,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String value;
  const _MiniStat(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
