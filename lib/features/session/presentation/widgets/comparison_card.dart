import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/math_speech.dart';
import '../../models/session_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class _Sticker {
  final String emoji;
  final double xFraction;
  final double yOffset;
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

// Parses "5 ___ 12: điền dấu so sánh" → (5, 12) or null
(int, int)? _parseComparison(String questionVi) {
  final re = RegExp(r'^(-?\d+)\s*___\s*(-?\d+)');
  final m = re.firstMatch(questionVi.trim());
  if (m == null) return null;
  final a = int.tryParse(m.group(1)!);
  final b = int.tryParse(m.group(2)!);
  if (a == null || b == null) return null;
  return (a, b);
}

class ComparisonCard extends ConsumerStatefulWidget {
  final SessionQuestion question;
  final int attemptCount;

  const ComparisonCard({
    super.key,
    required this.question,
    required this.attemptCount,
  });

  @override
  ConsumerState<ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends ConsumerState<ComparisonCard> {
  late List<_Sticker> _stickers;

  @override
  void initState() {
    super.initState();
    _stickers = _buildStickers();
    _speakQuestion();
  }

  @override
  void didUpdateWidget(ComparisonCard old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _stickers = _buildStickers();
      _speakQuestion();
    }
  }

  List<_Sticker> _buildStickers() {
    final rng = Random(widget.question.id.hashCode);
    return List.generate(7, (_) => _Sticker(
      emoji: _stickerPool[rng.nextInt(_stickerPool.length)],
      xFraction: rng.nextDouble(),
      yOffset: rng.nextDouble() * 120,
      fontSize: 16 + rng.nextDouble() * 12,
      opacity: 0.20 + rng.nextDouble() * 0.18,
    ));
  }

  String _ttsLang(String lang) => lang == 'en' ? 'en-US' : 'vi-VN';
  String _ttsSpeech(String lang) =>
      mathToSpeech(widget.question.questionVi, lang: lang);

  void _speakQuestion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final muted = ref.read(muteProvider);
      final lang = ref.read(authStateProvider).valueOrNull?.language ?? 'vi';
      ref.read(ttsHelperProvider).speak(_ttsSpeech(lang), muted: muted, language: _ttsLang(lang));
    });
  }

  Widget _numBox(int value) {
    return Container(
      width: 100,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _blankBox() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFA000), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA000).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(authStateProvider)
        .whenData((u) => u?.language ?? 'vi')
        .valueOrNull ?? 'vi';
    final parsed = _parseComparison(widget.question.questionVi);

    return GestureDetector(
      onTap: () {
        final muted = ref.read(muteProvider);
        ref.read(ttsHelperProvider).speak(_ttsSpeech(lang), muted: muted, language: _ttsLang(lang));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: LayoutBuilder(builder: (context, constraints) {
            final cardW = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Rainbow top bar
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF42A5F5),
                          Color(0xFFAB47BC),
                          Color(0xFFFF8F00),
                          Color(0xFF43A047),
                        ],
                      ),
                    ),
                  ),
                ),
                // Stickers
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
                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top row: skill emoji + speaker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('⚖️', style: TextStyle(fontSize: 28)),
                          GestureDetector(
                            onTap: () {
                              final muted = ref.read(muteProvider);
                              ref.read(ttsHelperProvider).speak(
                                _ttsSpeech(lang), muted: muted, language: _ttsLang(lang));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5C6BC0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF5C6BC0).withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.volume_up_rounded, color: Color(0xFF5C6BC0), size: 17),
                                  SizedBox(width: 5),
                                  Text('Nghe lại', style: TextStyle(color: Color(0xFF5C6BC0), fontSize: 12, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Comparison display: [num1]  [?]  [num2]
                      if (parsed != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _numBox(parsed.$1),
                            const SizedBox(width: 16),
                            _blankBox(),
                            const SizedBox(width: 16),
                            _numBox(parsed.$2),
                          ],
                        )
                      else
                        Text(
                          widget.question.questionVi,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                          textAlign: TextAlign.center,
                        ),

                      // Hint
                      if (widget.attemptCount >= 2 && widget.question.hintVi != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.amber.shade300, width: 1.5),
                          ),
                          child: Row(children: [
                            const Text('💡', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              widget.question.hintVi!,
                              style: TextStyle(fontSize: 14, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
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
