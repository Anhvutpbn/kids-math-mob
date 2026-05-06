import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/onboarding_data_provider.dart';

const _avatars = [
  'avatar_01', 'avatar_02', 'avatar_03', 'avatar_04',
  'avatar_05', 'avatar_06', 'avatar_07', 'avatar_08',
];

class AvatarPickScreen extends ConsumerWidget {
  const AvatarPickScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingDataProvider).avatarId;

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn nhân vật')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Bé muốn là nhân vật nào?',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              // Preview
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatars/$selected.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(_avatarEmoji(selected), style: const TextStyle(fontSize: 56)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (_, i) {
                    final id = _avatars[i];
                    final isSelected = id == selected;
                    return GestureDetector(
                      onTap: () => ref.read(onboardingDataProvider.notifier).update((s) => s.copyWith(avatarId: id)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/avatars/$id.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                              _avatarEmoji(id),
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/onboarding/placement'),
                child: const Text('Chọn nhân vật này! →'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _avatarEmoji(String id) {
    const emojis = ['🐱', '🐶', '🐸', '🐼', '🦊', '🐨', '🦁', '🐯'];
    final idx = int.tryParse(id.replaceAll('avatar_', '')) ?? 1;
    return emojis[(idx - 1) % emojis.length];
  }
}
