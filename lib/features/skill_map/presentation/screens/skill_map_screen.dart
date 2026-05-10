import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/skill_map_model.dart';
import '../providers/skill_map_provider.dart';
import '../widgets/skill_radar_chart.dart';

const _skillMeta = [
  (SkillId.SK01, '🔢', 'Nhận biết số 0-10'),
  (SkillId.SK02, '💯', 'Nhận biết số 0-100'),
  (SkillId.SK03, '🔢', 'Đếm số'),
  (SkillId.SK04, '⚖️', 'So sánh số'),
  (SkillId.SK05, '➕', 'Phép cộng đơn giản'),
  (SkillId.SK06, '➖', 'Phép trừ đơn giản'),
  (SkillId.SK07, '❓', 'Điền số còn thiếu'),
  (SkillId.SK08, '🏆', 'Chọn số lớn nhất / bé nhất'),
];

class SkillMapScreen extends ConsumerWidget {
  const SkillMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillMapAsync = ref.watch(skillMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ kỹ năng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(skillMapProvider.notifier).refresh(),
          ),
        ],
      ),
      body: skillMapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tải được dữ liệu', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(skillMapProvider.notifier).refresh(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (entries) => _SkillMapContent(entries: entries),
      ),
    );
  }
}

class _SkillMapContent extends StatelessWidget {
  final List<SkillMapEntry> entries;
  const _SkillMapContent({required this.entries});

  SkillMapEntry? _entryFor(SkillId id) {
    try {
      return entries.firstWhere((e) => e.skillId == id.name);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Radar chart
          Container(
            height: 300,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: entries.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu kỹ năng'))
                : SkillRadarChart(entries: entries),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendDot(color: AppColors.mastered, label: 'Thành thạo'),
                _LegendDot(color: AppColors.practicing, label: 'Ổn'),
                _LegendDot(color: AppColors.learning, label: 'Đang học'),
                _LegendDot(color: AppColors.beginner, label: 'Cần luyện'),
                _LegendDot(color: AppColors.locked, label: 'Chưa mở'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skill list
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Chi tiết từng kỹ năng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _skillMeta.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final (skillId, emoji, name) = _skillMeta[i];
              final entry = _entryFor(skillId);
              return _SkillRow(
                skillId: skillId,
                emoji: emoji,
                name: name,
                entry: entry,
                onTap: () => _showSkillDetail(context, skillId, emoji, name, entry),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showSkillDetail(
    BuildContext context,
    SkillId skillId,
    String emoji,
    String name,
    SkillMapEntry? entry,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SkillDetailSheet(
        skillId: skillId.name,
        emoji: emoji,
        name: name,
        entry: entry,
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillId skillId;
  final String emoji;
  final String name;
  final SkillMapEntry? entry;
  final VoidCallback onTap;

  const _SkillRow({
    required this.skillId,
    required this.emoji,
    required this.name,
    required this.entry,
    required this.onTap,
  });

  Color get _masteryColor {
    final m = entry?.mastery ?? 0;
    if (entry?.locked == true || m == 0) return AppColors.locked;
    if (m >= MasteryThreshold.practicing) return AppColors.mastered;
    if (m >= MasteryThreshold.learning) return AppColors.practicing;
    if (m >= MasteryThreshold.beginner) return AppColors.learning;
    return AppColors.beginner;
  }

  @override
  Widget build(BuildContext context) {
    final mastery = entry?.mastery ?? 0;
    final isLocked = entry?.locked ?? true;
    final color = _masteryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? AppColors.textLight : AppColors.textDark,
                      )),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mastery / 100.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isLocked)
              const Icon(Icons.lock_rounded, size: 18, color: AppColors.locked)
            else
              Text('$mastery%',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _SkillDetailSheet extends StatelessWidget {
  final String skillId;
  final String emoji;
  final String name;
  final SkillMapEntry? entry;

  const _SkillDetailSheet({required this.skillId, required this.emoji, required this.name, this.entry});

  String _errorTypeLabel(String? flag) {
    switch (flag) {
      case 'conceptual': return 'Lỗi khái niệm';
      case 'careless': return 'Lỗi bất cẩn';
      case 'speed': return 'Quá chậm';
      default: return 'Không có lỗi đặc biệt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mastery = entry?.mastery ?? 0;
    final isLocked = entry?.locked ?? true;
    final nextReview = entry?.nextReviewAt;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (isLocked) ...[
            const Icon(Icons.lock_rounded, size: 32, color: AppColors.locked),
            const SizedBox(height: 8),
            const Text('Cần hoàn thành kỹ năng trước để mở khóa',
                style: TextStyle(color: AppColors.textLight),
                textAlign: TextAlign.center),
          ] else ...[
            // Mastery bar
            Row(
              children: [
                const Text('Thành thạo:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: mastery / 100.0,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$mastery%',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Loại lỗi hay gặp', value: _errorTypeLabel(entry?.errorTypeFlag)),
            if (nextReview != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Ôn tập tiếp theo',
                value: '${nextReview.day.toString().padLeft(2, '0')}/'
                    '${nextReview.month.toString().padLeft(2, '0')}/'
                    '${nextReview.year}',
              ),
            ],
          ],
          const SizedBox(height: 24),
          if (!isLocked)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/skill-level-select', extra: {
                  'skillId': skillId,
                  'emoji': emoji,
                  'name': name,
                });
              },
              child: const Text('Luyện tập ngay →'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }
}
