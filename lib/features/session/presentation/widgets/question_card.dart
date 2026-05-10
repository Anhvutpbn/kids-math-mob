import 'dart:math';
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

// ── Sticker background data ───────────────────────────────────────────────────

class _Sticker {
  final String emoji;
  final double xFraction; // 0.0–1.0 of card width
  final double yOffset;   // px from top
  final double fontSize;
  final double opacity;
  const _Sticker({
    required this.emoji,
    required this.xFraction,
    required this.yOffset,
    required this.fontSize,
    required this.opacity,
  });
}

const _stickerPool = [
  '⭐', '🌟', '✨', '💫', '🎈', '🎉', '🦋',
  '🌈', '🌸', '🎯', '🐬', '🦄', '🌺', '🎁', '🔔',
  '🍭', '🎀', '🐥', '🌙', '❤️',
];

// ── State ─────────────────────────────────────────────────────────────────────

class _QuestionCardState extends ConsumerState<QuestionCard> {
  late List<_Sticker> _stickers;

  @override
  void initState() {
    super.initState();
    _stickers = _buildStickers();
    _speakQuestion();
  }

  @override
  void didUpdateWidget(QuestionCard old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _stickers = _buildStickers();
      _speakQuestion();
    }
  }

  List<_Sticker> _buildStickers() {
    final rng = Random(widget.question.id.hashCode);
    return List.generate(11, (_) => _Sticker(
      emoji: _stickerPool[rng.nextInt(_stickerPool.length)],
      xFraction: rng.nextDouble(),
      yOffset: rng.nextDouble() * 140,
      fontSize: 14 + rng.nextDouble() * 12,
      opacity: 0.13 + rng.nextDouble() * 0.14,
    ));
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
    final lang = ref.watch(authStateProvider)
        .whenData((u) => u?.language ?? 'vi')
        .valueOrNull ?? 'vi';

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
          border: Border.all(color: Colors.white54, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C6BC0).withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: LayoutBuilder(builder: (context, constraints) {
            final cardW = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ── Random sticker background ───────────────────────────────
                ..._stickers.map((s) => Positioned(
                  left: (s.xFraction * (cardW - 36)).clamp(4.0, cardW - 36),
                  top: s.yOffset,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: s.opacity,
                      child: Text(s.emoji, style: TextStyle(fontSize: s.fontSize)),
                    ),
                  ),
                )),

                // ── Decorative bubbles ──────────────────────────────────────
                const Positioned(
                  top: -28, right: -28,
                  child: SizedBox(
                    width: 100, height: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0x1AFFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: -36, left: -18,
                  child: SizedBox(
                    width: 120, height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0x12FFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // ── Main content ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _skillEmoji(widget.question.skillId),
                            style: const TextStyle(fontSize: 30),
                          ),
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
            );
          }),
        ),
      ),
    );
  }
}
