import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/badge_model.dart';

class LevelUpDialog extends StatelessWidget {
  final BadgeModel badge;
  const LevelUpDialog({super.key, required this.badge});

  static Future<void> show(BuildContext context, BadgeModel badge) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelUpDialog(badge: badge),
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
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text('Huy hiệu mới!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  badge.iconAsset,
                  width: 44, height: 44,
                  errorBuilder: (_, __, ___) => const Text('🏅', style: TextStyle(fontSize: 36)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(badge.nameVi,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(badge.descriptionVi,
                style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tuyệt vời! 🌟'),
            ),
          ],
        ),
      ),
    );
  }
}
