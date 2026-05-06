import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/session/models/session_models.dart';

/// Floating avatar in the corner of the session screen.
/// Reacts to answer feedback with Lottie animations.
class AvatarWidget extends ConsumerWidget {
  final AnswerFeedback feedback;
  const AvatarWidget({super.key, required this.feedback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final avatarId = user?.avatarId ?? 'avatar_01';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildContent(avatarId),
    );
  }

  Widget _buildContent(String avatarId) {
    // Show Lottie on feedback, otherwise show avatar image
    if (feedback == AnswerFeedback.correct) {
      return _LottieOrFallback(
        key: const ValueKey('correct'),
        asset: 'animations/correct_celebration.json',
        fallback: '🎉',
      );
    }
    if (feedback == AnswerFeedback.wrongAnswer) {
      return _LottieOrFallback(
        key: const ValueKey('wrong'),
        asset: 'animations/wrong_shake.json',
        fallback: '😅',
      );
    }
    return SizedBox(
      key: const ValueKey('avatar'),
      width: 64, height: 64,
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatars/$avatarId.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Text('😊', style: TextStyle(fontSize: 36)),
        ),
      ),
    );
  }
}

class _LottieOrFallback extends StatelessWidget {
  final String asset;
  final String fallback;
  const _LottieOrFallback({super.key, required this.asset, required this.fallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72, height: 72,
      child: Lottie.asset(
        'assets/$asset',
        repeat: false,
        errorBuilder: (_, __, ___) => Text(fallback, style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}
