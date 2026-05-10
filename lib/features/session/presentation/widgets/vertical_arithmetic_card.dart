import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/math_speech.dart';
import '../../models/session_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Parse "a + b = ?" into structured data ───────────────────────────────────

class VerticalArith {
  final int? op1;    // null if this slot is the blank
  final int? op2;
  final int? result;
  final String op;   // '+' or '-'
  final String blank; // 'op1' | 'op2' | 'result'

  const VerticalArith({
    required this.op1,
    required this.op2,
    required this.result,
    required this.op,
    required this.blank,
  });

  static VerticalArith? tryParse(String questionVi) {
    final re = RegExp(r'^(\?|\d+)\s*([+\-])\s*(\?|\d+)\s*=\s*(\?|\d+)$');
    final m = re.firstMatch(questionVi.trim());
    if (m == null) return null;
    final a = m.group(1)!;
    final operation = m.group(2)!;
    final b = m.group(3)!;
    final r = m.group(4)!;
    return VerticalArith(
      op1: a == '?' ? null : int.tryParse(a),
      op2: b == '?' ? null : int.tryParse(b),
      result: r == '?' ? null : int.tryParse(r),
      op: operation,
      blank: a == '?' ? 'op1' : b == '?' ? 'op2' : 'result',
    );
  }
}

// ── Sticker data ──────────────────────────────────────────────────────────────

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

// ── Widget ────────────────────────────────────────────────────────────────────

class VerticalArithmeticCard extends ConsumerStatefulWidget {
  final SessionQuestion question;
  final int attemptCount;

  const VerticalArithmeticCard({
    super.key,
    required this.question,
    required this.attemptCount,
  });

  @override
  ConsumerState<VerticalArithmeticCard> createState() => _VerticalArithmeticCardState();
}

class _VerticalArithmeticCardState extends ConsumerState<VerticalArithmeticCard> {
  late List<_Sticker> _stickers;

  @override
  void initState() {
    super.initState();
    _stickers = _buildStickers();
    _speakQuestion();
  }

  @override
  void didUpdateWidget(VerticalArithmeticCard old) {
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

  String _skillEmoji(String skillId) {
    switch (skillId) {
      case 'SK05': return '➕';
      case 'SK06': return '➖';
      default:     return '📚';
    }
  }

  // ── Number box ─────────────────────────────────────────────────────────────

  Widget _numBox(int? value, {required bool isBlank}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isBlank ? const Color(0xFFFFF9C4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBlank ? const Color(0xFFFFA000) : Colors.grey.shade200,
          width: isBlank ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isBlank
                ? const Color(0xFFFFA000).withOpacity(0.25)
                : Colors.black.withOpacity(0.08),
            blurRadius: isBlank ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value?.toString() ?? '?',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: isBlank ? const Color(0xFF9E9E9E) : const Color(0xFF1A237E),
            ),
          ),
        ),
      ),
    );
  }

  // ── Vertical layout ────────────────────────────────────────────────────────

  Widget _arithmeticLayout(VerticalArith va) {
    const opW = 48.0;
    const rowGap = 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Row 1: op1
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: opW),
            _numBox(va.op1, isBlank: va.blank == 'op1'),
          ],
        ),
        const SizedBox(height: rowGap),
        // Row 2: operator + op2
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: opW,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    va.op,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ),
            ),
            _numBox(va.op2, isBlank: va.blank == 'op2'),
          ],
        ),
        const SizedBox(height: 8),
        // Divider line
        LayoutBuilder(builder: (_, c) {
          final lineW = c.maxWidth.isFinite ? c.maxWidth : 160.0;
          return Container(
            width: lineW,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(height: 8),
        // Row 3: result
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: opW),
            _numBox(va.result, isBlank: va.blank == 'result'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(authStateProvider)
        .whenData((u) => u?.language ?? 'vi')
        .valueOrNull ?? 'vi';
    final va = VerticalArith.tryParse(widget.question.questionVi);

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
                          Text(
                            _skillEmoji(widget.question.skillId),
                            style: const TextStyle(fontSize: 28),
                          ),
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
                      const SizedBox(height: 16),

                      // Vertical arithmetic display
                      Center(
                        child: va != null
                            ? _arithmeticLayout(va)
                            : Text(
                                widget.question.questionVi,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                                textAlign: TextAlign.center,
                              ),
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
