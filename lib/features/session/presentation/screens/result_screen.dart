import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/mastered_skill_dialog.dart';
import '../../../skill_map/models/skill_map_model.dart';
import '../../../skill_map/presentation/providers/skill_map_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final int stars;
  final int xpEarned;
  final int correctCount;
  final int totalCount;
  final int previousXp;

  const ResultScreen({
    super.key,
    required this.stars,
    required this.xpEarned,
    required this.correctCount,
    required this.totalCount,
    this.previousXp = 0,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _masteredPopupShown = false;

  static const _skillEmojisMap = {
    'SK01': '🔢', 'SK02': '💯', 'SK03': '🔢',
    'SK04': '⚖️', 'SK05': '➕', 'SK06': '➖', 'SK07': '❓',
  };

  void _maybeShowMasteredPopup(List<SkillMapEntry> entries) {
    if (_masteredPopupShown) return;
    final mastered = entries.where((e) => e.mastery >= MasteryThreshold.practicing && !e.locked);
    if (mastered.isEmpty) return;
    _masteredPopupShown = true;
    final entry = mastered.first;
    final key = SkillId.values.firstWhere(
      (s) => s.name == entry.skillId, orElse: () => SkillId.SK01);
    final name = skills[key]?.nameVi ?? entry.skillId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        MasteredSkillDialog.show(context,
          emoji: _skillEmojisMap[entry.skillId] ?? '🔢',
          skillName: name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.totalCount > 0
        ? (widget.correctCount / widget.totalCount * 100).round()
        : 0;
    final skillMapAsync = ref.watch(skillMapProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < widget.stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300 + i * 150),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: filled ? AppColors.secondary : Colors.grey.shade300,
                        size: filled ? 72 : 56,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                _resultTitle(widget.stars),
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _resultSubtitle(widget.stars),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(label: 'Đúng', value: '${widget.correctCount}/${widget.totalCount}', icon: '✅'),
                  _StatCard(label: 'Chính xác', value: '$accuracy%', icon: '🎯'),
                  _StatCard(label: 'XP nhận', value: '+${widget.xpEarned}', icon: '⭐'),
                ],
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),
              // Animated XP bar
              if (widget.xpEarned > 0)
                _AnimatedXpBar(
                  previousXp: widget.previousXp,
                  xpEarned: widget.xpEarned,
                ),
              const SizedBox(height: 8),

              // Skill changes section + mastered popup trigger
              skillMapAsync.maybeWhen(
                data: (entries) {
                  _maybeShowMasteredPopup(entries);
                  return _SkillChangesSection(entries: entries);
                },
                orElse: () => const SizedBox(),
              ),

              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Về trang chủ 🏠'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.pop();
                  context.push('/session');
                },
                child: const Text('Học tiếp! →'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _resultTitle(int stars) {
    if (stars == 3) return '🏆 Xuất sắc!';
    if (stars == 2) return '😊 Tốt lắm!';
    return '💪 Cố lên!';
  }

  String _resultSubtitle(int stars) {
    if (stars == 3) return 'Bé làm rất tốt hôm nay!';
    if (stars == 2) return 'Tiếp tục luyện tập nhé!';
    return 'Lần sau sẽ tốt hơn!';
  }
}


class _AnimatedXpBar extends StatelessWidget {
  final int previousXp;
  final int xpEarned;
  const _AnimatedXpBar({required this.previousXp, required this.xpEarned});

  static const int _xpPerLevel = 200;

  @override
  Widget build(BuildContext context) {
    final newTotal = previousXp + xpEarned;
    final prevLevel = previousXp ~/ _xpPerLevel + 1;
    final newLevel = newTotal ~/ _xpPerLevel + 1;
    final prevProgress = (previousXp % _xpPerLevel) / _xpPerLevel;
    final newProgress = (newTotal % _xpPerLevel) / _xpPerLevel;
    final levelUp = newLevel > prevLevel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text('+ $xpEarned XP',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
              if (levelUp) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Level Up! → $newLevel',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
              const Spacer(),
              Text('Level $newLevel',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: prevProgress, end: newProgress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('${newTotal % _xpPerLevel} / $_xpPerLevel XP đến level tiếp theo',
              style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _SkillChangesSection extends StatelessWidget {
  final List<SkillMapEntry> entries;
  const _SkillChangesSection({required this.entries});

  static const _skillEmojis = {
    'SK01': '🔢', 'SK02': '💯', 'SK03': '🔢',
    'SK04': '⚖️', 'SK05': '➕', 'SK06': '➖', 'SK07': '❓',
  };

  String _skillName(String skillId) {
    final key = SkillId.values.firstWhere(
      (e) => e.name == skillId,
      orElse: () => SkillId.SK01,
    );
    return skills[key]?.nameVi ?? skillId;
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox();

    // Show top 3 skills with highest mastery (recently updated)
    final sorted = [...entries]
      ..removeWhere((e) => e.mastery == 0 || e.locked)
      ..sort((a, b) => b.mastery.compareTo(a.mastery));
    final topSkills = sorted.take(3).toList();
    if (topSkills.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kỹ năng của bé',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...topSkills.map((entry) => _SkillProgressRow(
            emoji: _skillEmojis[entry.skillId] ?? '🔢',
            name: _skillName(entry.skillId),
            mastery: entry.mastery,
          )),
        ],
      ),
    );
  }
}

class _SkillProgressRow extends StatelessWidget {
  final String emoji;
  final String name;
  final int mastery;
  const _SkillProgressRow({required this.emoji, required this.name, required this.mastery});

  Color get _color {
    if (mastery >= MasteryThreshold.practicing) return AppColors.mastered;
    if (mastery >= MasteryThreshold.learning) return AppColors.practicing;
    if (mastery >= MasteryThreshold.beginner) return AppColors.learning;
    return AppColors.beginner;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mastery / 100.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$mastery%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _color)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
