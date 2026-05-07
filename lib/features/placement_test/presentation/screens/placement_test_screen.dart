import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/providers/onboarding_data_provider.dart';
import '../providers/placement_test_provider.dart';

class PlacementTestScreen extends ConsumerWidget {
  const PlacementTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(placementTestProvider);

    return Scaffold(
      body: testAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Không thể tải bài kiểm tra: $e'),
              ElevatedButton(
                onPressed: () => ref.invalidate(placementTestProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (state) {
          if (state.isDone) {
            return _DoneView(
              onSubmit: () async {
                await ref.read(placementTestProvider.notifier).submit();
                final onboarding = ref.read(onboardingDataProvider);
                await ref.read(authStateProvider.notifier).completeOnboarding(
                  childName: onboarding.childName.isNotEmpty ? onboarding.childName : 'Bé',
                  childAge: onboarding.childAge,
                  avatarId: onboarding.avatarId,
                  language: onboarding.language,
                );
                if (context.mounted) context.go('/home');
              },
              isSubmitting: state.isSubmitting,
            );
          }

          final q = state.currentQuestion!;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(children: [
                    Text('Bài kiểm tra xếp lớp',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text('${state.currentIndex + 1}/${state.questions.length}',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 16)),
                  ]),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 40),
                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      q.questionVi,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Answers
                  if (q.type == 'multiple_choice')
                    ...q.options.map((opt) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AnswerButton(
                            label: opt,
                            onTap: () => ref.read(placementTestProvider.notifier).answer(opt),
                          ),
                        ))
                  else
                    _FillBlankInput(
                      onSubmit: (v) => ref.read(placementTestProvider.notifier).answer(v),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnswerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FillBlankInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _FillBlankInput({required this.onSubmit});

  @override
  State<_FillBlankInput> createState() => _FillBlankInputState();
}

class _FillBlankInputState extends State<_FillBlankInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          keyboardType: TextInputType.text,
          autofocus: true,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: '?'),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 64, height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: EdgeInsets.zero,
          ),
          onPressed: () { if (_ctrl.text.isNotEmpty) widget.onSubmit(_ctrl.text.trim()); },
          child: const Icon(Icons.check, size: 28),
        ),
      ),
    ]);
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isSubmitting;
  const _DoneView({required this.onSubmit, required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text('Hoàn thành!', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 12),
            Text('Chúng tôi đã hiểu được điểm mạnh của bé.\nSẵn sàng bắt đầu học chưa?',
                style: const TextStyle(fontSize: 18, color: AppColors.textLight),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Bắt đầu học! 🚀'),
            ),
          ],
        ),
      ),
    );
  }
}
