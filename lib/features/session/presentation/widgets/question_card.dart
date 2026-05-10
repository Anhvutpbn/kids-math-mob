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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F4FD), Color(0xFFF0E8FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Speaker hint
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            // Question text
            Text(
              _questionText(lang),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A237E),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            // Hint after 2nd wrong attempt
            if (widget.attemptCount >= 2 && widget.question.hintVi != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade300, width: 1.5),
                ),
                child: Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
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
