import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MasteredSkillDialog extends StatelessWidget {
  final String emoji;
  final String skillName;
  const MasteredSkillDialog({super.key, required this.emoji, required this.skillName});

  static Future<void> show(BuildContext context, {required String emoji, required String skillName}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MasteredSkillDialog(emoji: emoji, skillName: skillName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text('Thành thạo rồi!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.mastered.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 12),
            Text(skillName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('Bé đã thành thạo kỹ năng này rồi! Tuyệt vời lắm! 🎉',
                style: TextStyle(fontSize: 14, color: AppColors.textLight),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mastered),
              child: const Text('Cảm ơn! 💪'),
            ),
          ],
        ),
      ),
    );
  }
}
