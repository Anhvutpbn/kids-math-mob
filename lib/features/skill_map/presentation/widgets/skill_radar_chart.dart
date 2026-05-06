import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/skill_map_model.dart';

// Ordered list matching SkillId enum order for radar axes
const _skillLabels = [
  ('🔢', '0-10'),
  ('💯', '0-100'),
  ('🔢', 'Đếm'),
  ('⚖️', 'S.sánh'),
  ('➕', 'Cộng'),
  ('➖', 'Trừ'),
  ('❓', 'Điền số'),
  ('🏆', 'Min/Max'),
];

const _skillIds = [
  SkillId.SK01, SkillId.SK02, SkillId.SK03, SkillId.SK04,
  SkillId.SK05, SkillId.SK06, SkillId.SK07, SkillId.SK08,
];

class SkillRadarChart extends StatelessWidget {
  final List<SkillMapEntry> entries;
  const SkillRadarChart({super.key, required this.entries});

  double _masteryFor(SkillId id) {
    final entry = entries.firstWhere(
      (e) => e.skillId == id.name,
      orElse: () => SkillMapEntry(id: '', skillId: id.name),
    );
    return (entry.mastery / 100.0 * 5).clamp(0.0, 5.0);
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = _skillIds.map((id) => RadarEntry(value: _masteryFor(id))).toList();
    final avgColor = _averageColor();

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: dataPoints,
            fillColor: avgColor.withOpacity(0.25),
            borderColor: avgColor,
            borderWidth: 2.5,
            entryRadius: 4,
          ),
        ],
        radarShape: RadarShape.polygon,
        radarBorderData: const BorderSide(color: Colors.transparent),
        gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
        tickCount: 5,
        ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
        tickBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
        titleTextStyle: const TextStyle(fontSize: 11, color: AppColors.textDark),
        titlePositionPercentageOffset: 0.22,
        getTitle: (index, angle) {
          final (emoji, label) = _skillLabels[index];
          return RadarChartTitle(text: '$emoji\n$label', angle: angle);
        },
      ),
    );
  }

  Color _averageColor() {
    if (entries.isEmpty) return AppColors.locked;
    final avg = entries.fold<int>(0, (sum, e) => sum + e.mastery) ~/ entries.length;
    if (avg >= MasteryThreshold.practicing) return AppColors.mastered;
    if (avg >= MasteryThreshold.learning) return AppColors.practicing;
    if (avg >= MasteryThreshold.beginner) return AppColors.learning;
    if (avg > 0) return AppColors.beginner;
    return AppColors.locked;
  }
}
