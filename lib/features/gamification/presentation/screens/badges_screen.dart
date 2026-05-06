import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/gamification_provider.dart';
import '../widgets/badge_card.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Huy hiệu của bé'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tải được huy hiệu'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(badgesProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (badges) {
          final earned = badges.where((b) => b.earned).toList();
          final locked = badges.where((b) => !b.earned).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, Color(0xFFFFCC02)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${earned.length} / ${badges.length} huy hiệu',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          const Text('Tiếp tục học để mở khóa thêm!',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (earned.isNotEmpty) ...[
                  const _SectionHeader('Đã đạt được ✨'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    children: earned.map((b) => BadgeCard(badge: b)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                if (locked.isNotEmpty) ...[
                  const _SectionHeader('Chưa mở khóa 🔒'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    children: locked.map((b) => BadgeCard(badge: b)).toList(),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}
