import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/dashboard_models.dart';

class SessionHistoryList extends StatelessWidget {
  final List<SessionHistoryItem> sessions;
  const SessionHistoryList({super.key, required this.sessions});

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}p ${s}s' : '${m}p';
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Chưa có buổi học nào',
              style: TextStyle(color: AppColors.textLight, fontSize: 14)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => context.push(
          '/session-detail/${sessions[i].id}',
          extra: _formatDate(sessions[i].date),
        ),
        child: _SessionTile(
          session: sessions[i],
          formatDate: _formatDate,
          formatDuration: _formatDuration,
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionHistoryItem session;
  final String Function(String) formatDate;
  final String Function(int) formatDuration;

  const _SessionTile({
    required this.session,
    required this.formatDate,
    required this.formatDuration,
  });

  Color get _accuracyColor {
    final acc = session.totalCount > 0
        ? session.correctCount / session.totalCount * 100
        : 0;
    if (acc >= 80) return AppColors.mastered;
    if (acc >= 50) return AppColors.learning;
    return AppColors.beginner;
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = session.totalCount > 0
        ? (session.correctCount / session.totalCount * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          // Stars
          Column(
            children: List.generate(3, (i) => Icon(
              i < session.stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: i < session.stars ? AppColors.secondary : Colors.grey.shade300,
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDate(session.date),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${session.correctCount}/${session.totalCount} câu đúng · ${formatDuration(session.durationSeconds)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$accuracy%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _accuracyColor)),
              Text('+${session.xpEarned} XP',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
