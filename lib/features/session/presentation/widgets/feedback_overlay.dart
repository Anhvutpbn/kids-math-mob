import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/session_models.dart';

class FeedbackOverlay extends StatelessWidget {
  final AnswerFeedback feedback;
  final String? hintVi;
  final VoidCallback? onDismiss;

  const FeedbackOverlay({super.key, required this.feedback, this.hintVi, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (feedback == AnswerFeedback.correct) {
      return _FeedbackBanner(
        color: AppColors.correct,
        icon: '🎉',
        message: 'Tuyệt vời! Đúng rồi!',
      );
    }
    if (feedback == AnswerFeedback.wrongHint) {
      return _FeedbackBanner(
        color: AppColors.incorrect,
        icon: '🤔',
        message: hintVi ?? 'Thử lại nào!',
        isWrong: true,
        onDismiss: onDismiss,
      );
    }
    if (feedback == AnswerFeedback.wrongImage) {
      return _FeedbackBanner(
        color: AppColors.incorrect,
        icon: '💪',
        message: 'Cố lên! Hãy nhìn vào gợi ý.',
        isWrong: true,
        onDismiss: onDismiss,
      );
    }
    if (feedback == AnswerFeedback.wrongAnswer) {
      return _FeedbackBanner(
        color: Colors.orange,
        icon: '📚',
        message: 'Đáp án đúng là: ${hintVi ?? "..."}',
        isWrong: true,
        onDismiss: onDismiss,
      );
    }
    return const SizedBox.shrink();
  }
}

class _FeedbackBanner extends StatelessWidget {
  final Color color;
  final String icon;
  final String message;
  final bool isWrong;
  final VoidCallback? onDismiss;

  const _FeedbackBanner({
    required this.color,
    required this.icon,
    required this.message,
    this.isWrong = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: GestureDetector(
        onTap: isWrong ? onDismiss : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border(top: BorderSide(color: color, width: 3)),
          ),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isWrong ? AppColors.incorrect : AppColors.correct,
                ),
              ),
            ),
            if (isWrong)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text('Thử lại →',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              ),
          ]),
        ),
      ),
    );
  }
}
