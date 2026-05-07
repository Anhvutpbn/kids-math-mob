import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';
import '../../../skill_map/models/skill_map_model.dart';
import '../../../skill_map/presentation/providers/skill_map_provider.dart';
import '../providers/home_provider.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/streak_flame.dart';
import '../../../../shared/widgets/mute_button.dart';
import '../../../session/presentation/providers/session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: OfflineBanner(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Lỗi tải trang chủ')),
          data: (user) {
            if (user == null) return const SizedBox();
            return _HomeContent(user: user);
          },
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final UserModel user;
  const _HomeContent({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyReviewAsync = ref.watch(weeklyReviewAvailableProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatars/${user.avatarId}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('😊', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chào ${user.childName ?? "bé"}! 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                _TopIconButton(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.secondary,
                  onTap: () => context.push('/badges'),
                ),
                const SizedBox(width: 2),
                _TopIconButton(
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.accent,
                  onTap: () => context.push('/dashboard'),
                ),
                const SizedBox(width: 2),
                _LanguageToggle(language: user.language),
                const SizedBox(width: 2),
                const MuteButton(),
                const SizedBox(width: 2),
                _LogoutButton(),
              ],
            ),
            const SizedBox(height: 6),
            const _GreetingBubble(),
            const SizedBox(height: 14),

            // Weekly review banner
            weeklyReviewAsync.maybeWhen(
              data: (available) => available ? _WeeklyReviewBanner() : const SizedBox(),
              orElse: () => const SizedBox(),
            ),

            // Streak & XP bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF9800)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  StreakFlame(streak: user.streakCurrent, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.streakCurrent} ngày liên tiếp',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Giữ ngọn lửa nhé! 🔥',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.totalXp} XP',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'tổng điểm',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // XP progress bar
            _XpProgressBar(totalXp: user.totalXp),
            const SizedBox(height: 24),

            // Main action button — HỌC NGAY
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    ref.read(sessionFocusSkillProvider.notifier).state = null;
                    context.push('/session');
                  },
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📚', style: TextStyle(fontSize: 56)),
                        SizedBox(height: 10),
                        Text(
                          'Học ngay!',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick stats
            Row(
              children: [
                Expanded(child: _QuickStatCard(
                  icon: '🔥', label: 'Streak dài nhất',
                  value: '${user.streakLongest} ngày',
                  color: AppColors.secondary,
                )),
                const SizedBox(width: 14),
                Expanded(child: _QuickStatCard(
                  icon: '⭐', label: 'Tổng XP',
                  value: '${user.totalXp}',
                  color: AppColors.accent,
                )),
              ],
            ),
            const SizedBox(height: 24),

            // Skill map preview
            Row(
              children: [
                Text('Kỹ năng của bé', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/skill-map'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Xem tất cả →',
                        style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _SkillMapPreview(),
            const SizedBox(height: 20),

            // Memory Game card
            const _MemoryGameCard(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends ConsumerWidget {
  final String language;
  const _LanguageToggle({required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVi = language == 'vi';
    return GestureDetector(
      onTap: () => ref.read(authStateProvider.notifier).updateLanguage(isVi ? 'en' : 'vi'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          isVi ? '🇻🇳 VI' : '🇬🇧 EN',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TopIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _WeeklyReviewBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ôn tập tuần này!',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.accent)),
                SizedBox(height: 2),
                Text('Đã đến lúc ôn lại những bài đã học.',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.push('/session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Ôn ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _XpProgressBar extends StatelessWidget {
  final int totalXp;
  const _XpProgressBar({required this.totalXp});

  static const int _xpPerLevel = 200;

  int get _level => (totalXp / _xpPerLevel).floor() + 1;
  int get _xpInLevel => totalXp % _xpPerLevel;
  double get _progress => _xpInLevel / _xpPerLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$_level',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level $_level', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('$_xpInLevel / $_xpPerLevel XP',
                        style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillMapPreview extends ConsumerWidget {
  const _SkillMapPreview();

  static const _skillOrder = [
    SkillId.SK01, SkillId.SK02, SkillId.SK03, SkillId.SK04,
    SkillId.SK05, SkillId.SK06, SkillId.SK07, SkillId.SK08,
  ];
  static const _fallbackEmojis = ['🔢', '💯', '🖐️', '⚖️', '➕', '➖', '❓', '🏆'];
  static const _fallbackNames  = ['0-10', '0-100', 'Đếm', 'So sánh', 'Cộng', 'Trừ', 'Điền số', 'Min/Max'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillMapAsync = ref.watch(skillMapProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: skillMapAsync.when(
        loading: () => _SkillDotsRow(
          children: List.generate(8, (i) => _SkillDot(
            emoji: _fallbackEmojis[i],
            name: _fallbackNames[i],
            mastery: 0,
            locked: true,
            loading: true,
          )),
        ),
        error: (_, __) => _SkillDotsRow(
          children: List.generate(8, (i) => _SkillDot(
            emoji: _fallbackEmojis[i],
            name: _fallbackNames[i],
            mastery: 0,
            locked: true,
          )),
        ),
        data: (entries) {
          return _SkillDotsRow(
            children: List.generate(8, (i) {
              final id = _skillOrder[i];
              SkillMapEntry? entry;
              try {
                entry = entries.firstWhere((e) => e.skillId == id.name);
              } catch (_) {}
              final isLocked = entry?.locked ?? true;
              return _SkillDot(
                emoji: _fallbackEmojis[i],
                name: _fallbackNames[i],
                mastery: entry?.mastery ?? 0,
                locked: isLocked,
                onTap: isLocked
                    ? null
                    : () => _confirmStartSkill(
                          context,
                          ref,
                          skillId: id.name,
                          emoji: _fallbackEmojis[i],
                          name: _fallbackNames[i],
                        ),
              );
            }),
          );
        },
      ),
    );
  }

  void _confirmStartSkill(
    BuildContext context,
    WidgetRef ref, {
    required String skillId,
    required String emoji,
    required String name,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'Học "$name" nhé?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bé sẵn sàng chưa? 🎉',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Chưa', style: TextStyle(fontSize: 17)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ref.read(sessionFocusSkillProvider.notifier).state = skillId;
                        context.push('/session');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Học thôi! 🚀', style: TextStyle(fontSize: 17, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillDotsRow extends StatelessWidget {
  final List<Widget> children;
  const _SkillDotsRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children
            .expand((dot) => [dot, const SizedBox(width: 8)])
            .toList()
            ..removeLast(),
      ),
    );
  }
}

class _SkillDot extends StatelessWidget {
  final String emoji;
  final String name;
  final int mastery;
  final bool locked;
  final bool loading;
  final VoidCallback? onTap;

  const _SkillDot({
    required this.emoji,
    required this.name,
    required this.mastery,
    required this.locked,
    this.loading = false,
    this.onTap,
  });

  Color get _color {
    if (locked || mastery == 0) return AppColors.locked;
    if (mastery >= MasteryThreshold.practicing) return AppColors.mastered;
    if (mastery >= MasteryThreshold.learning) return AppColors.practicing;
    if (mastery >= MasteryThreshold.beginner) return AppColors.learning;
    return AppColors.beginner;
  }

  @override
  Widget build(BuildContext context) {
    final dot = Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: loading ? Colors.grey.shade200 : _color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: loading ? Colors.grey.shade300 : _color, width: 2.5),
          ),
          child: Center(
            child: Text(
              locked ? '🔒' : emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: Text(
            name,
            style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!locked && mastery > 0)
          Text(
            '$mastery%',
            style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w700),
          ),
      ],
    );

    if (onTap == null) return dot;
    return GestureDetector(
      onTap: onTap,
      child: dot,
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Đăng xuất?'),
            content: const Text('Bạn có chắc muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(authStateProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        }
      },
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
      ),
    );
  }
}

class _MemoryGameCard extends StatelessWidget {
  const _MemoryGameCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/memory-game'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF7B1FA2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B1FA2).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🧠', style: TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siêu Trí Tuệ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ghi nhớ số · 16 cấp độ · 5 tier huy hiệu',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}

class _GreetingBubble extends StatefulWidget {
  const _GreetingBubble();

  @override
  State<_GreetingBubble> createState() => _GreetingBubbleState();
}

class _GreetingBubbleState extends State<_GreetingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 4), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted || _dismissed) return;
    await _ctrl.reverse();
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: _dismiss,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bubble tail — small rotated square pointing up toward avatar
              Positioned(
                left: 24,
                top: 0,
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
                    ),
                  ),
                ),
              ),
              // Bubble body
              Container(
                margin: const EdgeInsets.only(top: 7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🤔', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    const Text(
                      'Hôm nay học gì nhỉ?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.close_rounded, size: 15, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
