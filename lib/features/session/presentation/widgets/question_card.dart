import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String _skillEmoji(String skillId) {
    switch (skillId) {
      case 'SK01':
      case 'SK02': return '🔢';
      case 'SK03': return '🧮';
      case 'SK04': return '⚖️';
      case 'SK05': return '➕';
      case 'SK06': return '➖';
      case 'SK07': return '❓';
      case 'SK08': return '🏆';
      default:     return '📚';
    }
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C6BC0).withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Decorative bubbles in background
              Positioned(
                top: -28, right: -28,
                child: Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0x1AFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -36, left: -18,
                child: Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0x12FFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 20, left: -10,
                child: Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0x0FFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skill emoji badge
                        Text(
                          _skillEmoji(widget.question.skillId),
                          style: const TextStyle(fontSize: 30),
                        ),
                        // Speaker button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Nghe lại',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Question text
                    Text(
                      _questionText(lang),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            widget.question.hintVi!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ]),
                      ),
                    ],
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
