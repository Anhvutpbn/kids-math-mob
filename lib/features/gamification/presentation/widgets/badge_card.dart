import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;

    return Opacity(
      opacity: earned ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: earned ? AppColors.secondary.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned ? AppColors.secondary.withOpacity(0.5) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: earned ? AppColors.secondary.withOpacity(0.15) : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      badge.iconAsset,
                      width: 36, height: 36,
                      errorBuilder: (_, __, ___) => Text(
                        earned ? '🏅' : '🔒',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
                if (earned)
                  const Positioned(
                    child: Icon(Icons.check_circle, size: 18, color: AppColors.mastered),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.nameVi,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: earned ? AppColors.textDark : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge.condition != null) ...[
              const SizedBox(height: 4),
              Text(
                badge.condition!,
                style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
