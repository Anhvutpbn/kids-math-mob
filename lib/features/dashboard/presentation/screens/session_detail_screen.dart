import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/dashboard_api.dart';
import '../../models/dashboard_models.dart';

final _sessionDetailProvider =
    FutureProvider.family<List<SessionQuestionDetail>, String>((ref, sessionId) {
  return ref.read(dashboardApiProvider).getSessionDetail(sessionId);
});

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;
  final String date;
  const SessionDetailScreen({super.key, required this.sessionId, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_sessionDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết: $date'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được chi tiết buổi học')),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('Không có dữ liệu câu hỏi'));
          }
          final correct = questions.where((q) => q.isCorrect).length;
          final accuracy = (correct / questions.length * 100).round();

          return Column(
            children: [
              // Summary bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SummaryChip(label: 'Đúng', value: '$correct/${questions.length}', color: AppColors.mastered),
                    _SummaryChip(label: 'Chính xác', value: '$accuracy%', color: AppColors.accent),
                    _SummaryChip(
                      label: 'Thời gian TB',
                      value: _avgTime(questions),
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _QuestionDetailTile(
                    index: i + 1,
                    detail: questions[i],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _avgTime(List<SessionQuestionDetail> qs) {
    if (qs.isEmpty) return '0s';
    final avg = qs.fold<int>(0, (s, q) => s + q.timeSpentMs) ~/ qs.length;
    return avg >= 1000 ? '${(avg / 1000).toStringAsFixed(1)}s' : '${avg}ms';
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }
}

class _QuestionDetailTile extends StatelessWidget {
  final int index;
  final SessionQuestionDetail detail;
  const _QuestionDetailTile({required this.index, required this.detail});

  Color get _borderColor {
    if (detail.isCorrect) return AppColors.mastered;
    switch (detail.errorType) {
      case 'conceptual': return AppColors.beginner;
      case 'careless': return AppColors.practicing;
      case 'speed': return AppColors.accent.withOpacity(0.7);
      default: return AppColors.beginner;
    }
  }

  String get _errorLabel {
    if (detail.isCorrect) return '';
    switch (detail.errorType) {
      case 'conceptual': return 'Lỗi khái niệm';
      case 'careless': return 'Bất cẩn';
      case 'speed': return 'Chậm';
      default: return 'Sai';
    }
  }

  String _formatTime(int ms) {
    if (ms >= 1000) return '${(ms / 1000).toStringAsFixed(1)}s';
    return '${ms}ms';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _borderColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$index',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _borderColor)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(detail.questionVi,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Icon(
                detail.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: detail.isCorrect ? AppColors.mastered : AppColors.beginner,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Answer row
          Row(
            children: [
              _AnswerChip(
                label: 'Bé trả lời',
                value: detail.submittedAnswer,
                correct: detail.isCorrect,
              ),
              if (!detail.isCorrect) ...[
                const SizedBox(width: 8),
                _AnswerChip(
                  label: 'Đáp án đúng',
                  value: detail.correctAnswer,
                  correct: true,
                ),
              ],
              const Spacer(),
              Text(_formatTime(detail.timeSpentMs),
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          if (!detail.isCorrect && _errorLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_errorLabel,
                  style: TextStyle(fontSize: 11, color: _borderColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final String value;
  final bool correct;
  const _AnswerChip({required this.label, required this.value, required this.correct});

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.mastered : AppColors.beginner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }
}
