import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';

class SkillLevelSelectScreen extends ConsumerWidget {
  final String skillId;
  final String emoji;
  final String name;

  const SkillLevelSelectScreen({
    super.key,
    required this.skillId,
    required this.emoji,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Chọn cấp độ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Skill badge
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn cấp độ phù hợp với bé',
              style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 40),

            // Level cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _LevelCard(
                      difficulty: 1,
                      label: 'Dễ',
                      icon: '🌱',
                      stars: 1,
                      description: _levelDescription(skillId, 1),
                      color: const Color(0xFF43A047),
                      onTap: () => _startSession(context, ref, 1),
                    ),
                    const SizedBox(height: 16),
                    _LevelCard(
                      difficulty: 2,
                      label: 'Khó',
                      icon: '🔥',
                      stars: 2,
                      description: _levelDescription(skillId, 2),
                      color: const Color(0xFFE65100),
                      onTap: () => _startSession(context, ref, 2),
                    ),
                    const SizedBox(height: 16),
                    _LevelCard(
                      difficulty: 3,
                      label: 'Chuyên nghiệp',
                      icon: '👑',
                      stars: 3,
                      description: _levelDescription(skillId, 3),
                      color: const Color(0xFF6A1B9A),
                      onTap: () => _startSession(context, ref, 3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _levelDescription(String skillId, int difficulty) {
    switch (skillId) {
      case 'SK05': // Phép cộng
        return switch (difficulty) {
          1 => 'Kết quả trong phạm vi 10',
          2 => 'Kết quả trong phạm vi 50',
          _ => 'Kết quả trong phạm vi 100',
        };
      case 'SK06': // Phép trừ
        return switch (difficulty) {
          1 => 'Số trừ trong phạm vi 10',
          2 => 'Số trừ trong phạm vi 50',
          _ => 'Số trừ trong phạm vi 100',
        };
      case 'SK04': // So sánh
        return switch (difficulty) {
          1 => 'So sánh số trong phạm vi 50',
          2 => 'So sánh số trong phạm vi 500',
          _ => 'So sánh số trong phạm vi 9999',
        };
      case 'SK08': // Min/Max
        return switch (difficulty) {
          1 => 'Số trong phạm vi 20',
          2 => 'Số trong phạm vi 50',
          _ => 'Số trong phạm vi 100',
        };
      default:
        return switch (difficulty) {
          1 => '12 câu cơ bản',
          2 => '12 câu nâng cao',
          _ => '12 câu thử thách',
        };
    }
  }

  void _startSession(BuildContext context, WidgetRef ref, int difficulty) {
    ref.read(sessionFocusSkillProvider.notifier).state = skillId;
    ref.read(sessionFocusDifficultyProvider.notifier).state = difficulty;
    context.push('/session');
  }
}

class _LevelCard extends StatelessWidget {
  final int difficulty;
  final String label;
  final String icon;
  final int stars;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _LevelCard({
    required this.difficulty,
    required this.label,
    required this.icon,
    required this.stars,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha(204)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    stars,
                    (_) => const Text('⭐', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
