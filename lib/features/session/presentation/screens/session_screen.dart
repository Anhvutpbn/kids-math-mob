import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/session_models.dart';
import '../providers/session_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/vertical_arithmetic_card.dart';
import '../widgets/answer_options.dart';
import '../widgets/feedback_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../../../shared/widgets/mute_button.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😢', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('Không thể tải bài học: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sessionProvider),
                child: const Text('Thử lại'),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
        data: (state) {
          // Tutorial injection
          if (state.injectTutorial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.push('/tutorial', extra: state.tutorialSkillId).then((_) {
                ref.read(sessionProvider.notifier).clearTutorial();
              });
            });
          }

          // Session done → end and go to result
          if (state.isDone && state.summary == null) {
            final previousXp = ref.read(authStateProvider).valueOrNull?.totalXp ?? 0;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final summary = await ref.read(sessionProvider.notifier).endSession();
              if (context.mounted) {
                context.go('/result', extra: {
                  'stars': summary?.stars ?? 1,
                  'xpEarned': summary?.xpEarned ?? 0,
                  'correctCount': summary?.correctCount ?? 0,
                  'totalCount': state.results.length,
                  'previousXp': previousXp,
                });
                // Reset skill-focus state after session ends
                ref.read(sessionFocusSkillProvider.notifier).state = null;
                ref.read(sessionFocusDifficultyProvider.notifier).state = null;
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          final q = state.currentQuestion;
          if (q == null) return const SizedBox();

          return Container(
            color: const Color(0xFFFFFBF0),
            child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _showQuitDialog(context, ref),
                        ),
                        const MuteButton(size: 20),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${state.currentIndex + 1}/${state.questions.length}',
                            style: const TextStyle(color: AppColors.textLight)),
                      ]),
                      const SizedBox(height: 24),
                      if (q.type == 'vertical_arithmetic')
                        VerticalArithmeticCard(question: q, attemptCount: state.attemptCount)
                      else
                        QuestionCard(question: q, attemptCount: state.attemptCount),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 480),
                            child: AnswerOptions(
                              question: q,
                              onAnswer: _onAnswer(ref, q),
                              enabled: state.feedback == AnswerFeedback.none,
                              showHints: ref.watch(showArithmeticHintsProvider),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Feedback overlay
                if (state.feedback != AnswerFeedback.none)
                  FeedbackOverlay(
                    feedback: state.feedback,
                    hintVi: q.hintVi,
                    onDismiss: () => ref.read(sessionProvider.notifier).clearFeedback(),
                  ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  ValueChanged<String> _onAnswer(WidgetRef ref, SessionQuestion q) {
    return (answer) async {
      await ref.read(sessionProvider.notifier).submitAnswer(answer);
      final isCorrect = answer.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
      if (isCorrect) {
        ref.read(audioHelperProvider).playCorrect();
      } else {
        ref.read(audioHelperProvider).playWrong();
      }
    };
  }

  void _showQuitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bỏ cuộc?'),
        content: const Text('Tiến trình bài học sẽ không được lưu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tiếp tục học')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Bỏ cuộc'),
          ),
        ],
      ),
    );
  }
}
