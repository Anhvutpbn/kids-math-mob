import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../skill_map/presentation/providers/skill_map_provider.dart';
import '../../../skill_map/presentation/widgets/skill_radar_chart.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/progress_chart.dart';
import '../widgets/session_history_list.dart';
import '../widgets/weak_skill_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _unlocked = false;
  int _tapCount = 0;

  void _handleTitleTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      setState(() => _unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          child: const Text('Báo cáo phụ huynh'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).loadAll(),
          ),
        ],
      ),
      body: _unlocked ? const _DashboardContent() : const _LockGate(),
    );
  }
}

class _LockGate extends StatelessWidget {
  const _LockGate();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Khu vực phụ huynh',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Chạm vào tiêu đề 5 lần để mở khóa',
                style: TextStyle(fontSize: 15, color: AppColors.textLight),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final skillMapAsync = ref.watch(skillMapProvider);

    if (state.isLoading && state.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Không tải được dữ liệu', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(dashboardProvider.notifier).loadAll(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final summary = state.summary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          if (summary != null) ...[
            Row(
              children: [
                Expanded(child: _SummaryCard(
                  icon: '🔥', label: 'Streak hiện tại',
                  value: '${summary.streakCurrent} ngày',
                  color: AppColors.secondary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(
                  icon: '⭐', label: 'Tổng XP',
                  value: '${summary.totalXp}',
                  color: AppColors.accent,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _SummaryCard(
                  icon: '📚', label: 'Buổi học tuần này',
                  value: '${summary.sessionsThisWeek}',
                  color: AppColors.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(
                  icon: '🎯', label: 'Độ chính xác TB',
                  value: '${summary.avgAccuracyThisWeek}%',
                  color: const Color(0xFF9C27B0),
                )),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Skill Radar Chart
          const _SectionTitle('Bản đồ kỹ năng'),
          const SizedBox(height: 12),
          Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: skillMapAsync.maybeWhen(
              data: (entries) => entries.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu'))
                  : SkillRadarChart(entries: entries),
              orElse: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 24),

          // Weekly progress chart
          const _SectionTitle('Điểm XP theo ngày (7 ngày qua)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: ProgressChart(data: state.weeklyProgress),
          ),
          const SizedBox(height: 24),

          // AI Insight
          if (state.insight != null && state.insight!.summary.isNotEmpty) ...[
            const _SectionTitle('Nhận xét AI'),
            const SizedBox(height: 12),
            _AiInsightCard(insight: state.insight!),
            const SizedBox(height: 24),
          ],

          // Weak skills
          if (state.weakSkills.isNotEmpty) ...[
            const _SectionTitle('Điểm cần cải thiện'),
            const SizedBox(height: 12),
            ...state.weakSkills.take(3).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WeakSkillCard(skill: s),
            )),
            const SizedBox(height: 24),
          ],

          // Session history
          _SectionTitle('Lịch sử buổi học', trailing: _HistoryRangeFilter(
            selected: state.historyRange,
            onChanged: (r) => ref.read(dashboardProvider.notifier).changeHistoryRange(r),
          )),
          const SizedBox(height: 12),
          SessionHistoryList(sessions: state.sessionHistory),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  final dynamic insight;
  const _AiInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Phân tích AI',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.summary,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
          if (insight.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...List<String>.from(insight.tips).map((tip) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.accent)),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

class _HistoryRangeFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _HistoryRangeFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['7d', '30d', 'all'].map((r) {
        final label = r == '7d' ? '7 ngày' : r == '30d' ? '30 ngày' : 'Tất cả';
        final active = selected == r;
        return GestureDetector(
          onTap: () => onChanged(r),
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textLight,
                )),
          ),
        );
      }).toList(),
    );
  }
}
