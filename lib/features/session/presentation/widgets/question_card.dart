import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/math_speech.dart';
import '../../models/session_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class QuestionCard extends ConsumerStatefulWidget {
  final SessionQuestion question;
  final int attemptCount;

  const QuestionCard({super.key, required this.question, required this.attemptCount});

  @override
  ConsumerState<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<QuestionCard> {
  @override
  void initState() {
    super.initState();
    _speakQuestion();
  }

  @override
  void didUpdateWidget(QuestionCard old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _speakQuestion();
    }
  }

  String _questionText(String lang) {
    if (lang == 'en' && widget.question.questionEn != null && widget.question.questionEn!.isNotEmpty) {
      return widget.question.questionEn!;
    }
    final vi = widget.question.questionVi;
    if (vi.isNotEmpty) return vi;
    return widget.question.questionEn ?? vi;
  }

  String _ttsLang(String lang) => lang == 'en' ? 'en-US' : 'vi-VN';

  String _ttsSpeech(String lang) => mathToSpeech(_questionText(lang), lang: lang);

  void _speakQuestion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final muted = ref.read(muteProvider);
      final lang = ref.read(authStateProvider).valueOrNull?.language ?? 'vi';
      ref.read(ttsHelperProvider).speak(_ttsSpeech(lang), muted: muted, language: _ttsLang(lang));
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(authStateProvider).whenData((u) => u?.language ?? 'vi').valueOrNull ?? 'vi';
    return GestureDetector(
      onTap: () {
        final muted = ref.read(muteProvider);
        ref.read(ttsHelperProvider).speak(_ttsSpeech(lang), muted: muted, language: _ttsLang(lang));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            // Skill badge + tap-to-listen hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.question.skillId,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.textLight),
              ],
            ),
            const SizedBox(height: 20),
            // Question text — ≥28sp per accessibility requirement
            Text(
              _questionText(lang),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.5),
              textAlign: TextAlign.center,
            ),
            // Hint after 2nd wrong attempt
            if (widget.attemptCount >= 2 && widget.question.hintVi != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    widget.question.hintVi!,
                    style: const TextStyle(fontSize: 16, color: AppColors.textDark),
                  )),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
