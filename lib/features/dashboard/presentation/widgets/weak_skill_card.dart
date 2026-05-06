import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/dashboard_models.dart';

class WeakSkillCard extends StatelessWidget {
  final WeakSkill skill;
  const WeakSkillCard({super.key, required this.skill});

  static const _skillEmojis = {
    'SK01': '🔢', 'SK02': '💯', 'SK03': '🔢',
    'SK04': '⚖️', 'SK05': '➕', 'SK06': '➖', 'SK07': '❓',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _skillEmojis[skill.skillId] ?? '📚';
    final mastery = skill.mastery;

    Color color;
    if (mastery >= 60) color = AppColors.practicing;
    else if (mastery >= 30) color = AppColors.learning;
    else color = AppColors.beginner;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.skillNameVi,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mastery / 100.0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                if (skill.suggestion != null) ...[
                  const SizedBox(height: 4),
                  Text(skill.suggestion!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$mastery%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
