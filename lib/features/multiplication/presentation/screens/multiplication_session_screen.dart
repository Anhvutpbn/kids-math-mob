import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../shared/widgets/mute_button.dart';
import '../../models/multiplication_models.dart';
import '../providers/multiplication_provider.dart';
import '../widgets/number_pad.dart';

class MultiplicationSessionScreen extends ConsumerStatefulWidget {
  final MultiLevelConfig config;
  const MultiplicationSessionScreen({super.key, required this.config});

  @override
  ConsumerState<MultiplicationSessionScreen> createState() =>
      _MultiplicationSessionScreenState();
}

class _MultiplicationSessionScreenState
    extends ConsumerState<MultiplicationSessionScreen>
    with SingleTickerProviderStateMixin {
  bool _resultSaved = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(multiplicationSessionProvider.notifier).startSession(widget.config);
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final correct =
        ref.read(multiplicationSessionProvider.notifier).confirm();
    if (correct) {
      ref.read(audioHelperProvider).playCorrect();
      // TTS for next question is handled by ref.listen (currentIndex change)
    } else {
      ref.read(audioHelperProvider).playWrong();
      HapticFeedback.vibrate();
      _shakeCtrl.forward(from: 0);
    }
  }

  void _speakCurrentQuestion() {
    final s = ref.read(multiplicationSessionProvider);
    if (s == null) return;
    final q = s.currentQuestion;
    if (q == null) return;
    final muted = ref.read(muteProvider);
    ref.read(ttsHelperProvider).speak(q.ttsText, muted: muted);
  }

  void _saveAndShowResult(MultiplicationSessionState s) async {
    if (_resultSaved) return;
    _resultSaved = true;
    await ref.read(multiplicationSessionProvider.notifier).saveResult();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(multiplicationSessionProvider);

    // Auto-speak when question changes
    ref.listen<MultiplicationSessionState?>(
      multiplicationSessionProvider,
      (prev, next) {
        if (next == null) return;
        // New question appeared
        if (prev?.currentIndex != next.currentIndex && !next.isDone) {
          Future.microtask(_speakCurrentQuestion);
        }
        // Session done
        if (next.isDone && prev?.isDone == false) {
          _saveAndShowResult(next);
        }
        // Wrong feedback ended → re-speak
        if (prev?.phase == MultiplicationPhase.wrongFeedback &&
            next.phase == MultiplicationPhase.answering) {
          Future.microtask(_speakCurrentQuestion);
        }
      },
    );

    if (sessionState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8E1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  _TopBar(state: sessionState),
                  const SizedBox(height: 16),
                  _QuestionCard(
                    state: sessionState,
                    shakeAnim: _shakeAnim,
                  ),
                  const SizedBox(height: 12),
                  _TtsButton(onTap: _speakCurrentQuestion),
                  const SizedBox(height: 12),
                  _InputDisplay(state: sessionState),
                  const SizedBox(height: 16),
                  NumberPad(
                    onDigit: (d) => ref
                        .read(multiplicationSessionProvider.notifier)
                        .appendDigit(d),
                    onBackspace: () =>
                        ref.read(multiplicationSessionProvider.notifier).backspace(),
                    onConfirm: sessionState.input.isEmpty ? null : _handleConfirm,
                    enabled: sessionState.phase == MultiplicationPhase.answering &&
                        !sessionState.isDone,
                  ),
                ],
              ),
            ),
            // Done overlay
            if (sessionState.isDone)
              _DoneOverlay(state: sessionState, config: widget.config),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final MultiplicationSessionState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showQuit(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x18000000), blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF666666)),
          ),
        ),
        const SizedBox(width: 10),
        _HeartsRow(heartsLeft: state.heartsLeft, maxHearts: state.config.maxHearts),
        const Spacer(),
        Text(
          '${state.currentIndex < state.totalCount ? state.currentIndex + 1 : state.totalCount}/${state.totalCount}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8D6E63),
          ),
        ),
        const SizedBox(width: 8),
        const MuteButton(size: 20),
      ],
    );
  }

  void _showQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bỏ cuộc?'),
        content: const Text('Kết quả sẽ không được lưu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Học tiếp')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Bỏ cuộc'),
          ),
        ],
      ),
    );
  }
}

class _HeartsRow extends StatelessWidget {
  final int heartsLeft;
  final int maxHearts;
  const _HeartsRow({required this.heartsLeft, required this.maxHearts});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (i) {
        final full = i < heartsLeft;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            full ? '❤️' : '🖤',
            style: const TextStyle(fontSize: 20),
          ),
        );
      }),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

// ─── Question Card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final MultiplicationSessionState state;
  final Animation<double> shakeAnim;
  const _QuestionCard({required this.state, required this.shakeAnim});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    if (q == null) return const SizedBox();
    final isWrong = state.phase == MultiplicationPhase.wrongFeedback;

    return AnimatedBuilder(
      animation: shakeAnim,
      builder: (_, child) {
        final offset = isWrong
            ? Offset(8 * (0.5 - shakeAnim.value).abs() * (shakeAnim.value < 0.5 ? -1 : 1), 0)
            : Offset.zero;
        return Transform.translate(offset: offset, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: isWrong ? const Color(0xFFFFEBEE) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isWrong ? Colors.redAccent : const Color(0xFFFFCC02),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isWrong
                  ? Colors.red.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table hint
            Text(
              _tableHint(q),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Equation row
            _EquationRow(question: q, input: state.input, isWrong: isWrong),
          ],
        ),
      ),
    );
  }

  String _tableHint(MultiplicationQuestion q) => '× Bảng nhân ${q.a}';
}

class _EquationRow extends StatelessWidget {
  final MultiplicationQuestion question;
  final String input;
  final bool isWrong;

  const _EquationRow({
    required this.question,
    required this.input,
    required this.isWrong,
  });

  @override
  Widget build(BuildContext context) {
    const numStyle = TextStyle(
      fontSize: 44,
      fontWeight: FontWeight.w900,
      color: Color(0xFF333333),
    );
    const opStyle = TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w700,
      color: Color(0xFFE65100),
    );

    Widget numBox(int value, bool isUnknown) {
      if (!isUnknown) {
        return Text('$value', style: numStyle);
      }
      final displayText = input.isEmpty ? '?' : input;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minWidth: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isWrong
              ? Colors.red.withOpacity(0.15)
              : const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWrong ? Colors.redAccent : const Color(0xFFFFB300),
            width: 2.5,
          ),
        ),
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          style: numStyle.copyWith(
            color: isWrong
                ? Colors.redAccent
                : input.isEmpty
                    ? Colors.grey
                    : const Color(0xFFE65100),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        numBox(question.a, question.type == QuestionType.missingLeft),
        const SizedBox(width: 10),
        const Text('×', style: opStyle),
        const SizedBox(width: 10),
        numBox(question.b, question.type == QuestionType.missingRight),
        const SizedBox(width: 10),
        const Text('=', style: opStyle),
        const SizedBox(width: 10),
        numBox(question.result, question.type == QuestionType.missingResult),
      ],
    );
  }
}

// ─── TTS Button ──────────────────────────────────────────────────────────────

class _TtsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TtsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF8F00).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFFE65100)),
            SizedBox(width: 6),
            Text(
              'Đọc lại',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFE65100),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input Display ────────────────────────────────────────────────────────────

class _InputDisplay extends StatelessWidget {
  final MultiplicationSessionState state;
  const _InputDisplay({required this.state});

  @override
  Widget build(BuildContext context) {
    final isWrong = state.phase == MultiplicationPhase.wrongFeedback;
    final hasInput = state.input.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWrong
              ? Colors.redAccent
              : hasInput
                  ? const Color(0xFFFFB300)
                  : const Color(0xFFDDDDDD),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, size: 18, color: Color(0xFFBBBBBB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.input.isEmpty ? 'Nhập đáp án...' : state.input,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: state.input.isEmpty
                    ? const Color(0xFFCCCCCC)
                    : isWrong
                        ? Colors.redAccent
                        : const Color(0xFF333333),
              ),
            ),
          ),
          if (isWrong)
            const Text('✗', style: TextStyle(fontSize: 22, color: Colors.redAccent))
          else if (hasInput)
            const Icon(Icons.backspace_outlined, size: 18, color: Color(0xFFBBBBBB)),
        ],
      ),
    );
  }
}

// ─── Done Overlay ─────────────────────────────────────────────────────────────

class _DoneOverlay extends StatefulWidget {
  final MultiplicationSessionState state;
  final MultiLevelConfig config;
  const _DoneOverlay({required this.state, required this.config});

  @override
  State<_DoneOverlay> createState() => _DoneOverlayState();
}

class _DoneOverlayState extends State<_DoneOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passed = widget.state.passed;
    final secs = (widget.state.durationMs / 1000).toStringAsFixed(1);

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    passed ? '🎉' : '😢',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed ? 'Xuất Sắc!' : 'Hết Tim Rồi!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: passed ? const Color(0xFF2E7D32) : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Score
                  _ScoreRow(
                    correctCount: widget.state.correctCount,
                    totalCount: widget.state.totalCount,
                    heartsLeft: widget.state.heartsLeft,
                    maxHearts: widget.config.maxHearts,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⏱ $secs giây',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Về nhà'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.pushReplacement(
                              '/multiplication/session',
                              extra: widget.config,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: passed
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            passed ? 'Chơi lại 🚀' : 'Thử lại 💪',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int heartsLeft;
  final int maxHearts;

  const _ScoreRow({
    required this.correctCount,
    required this.totalCount,
    required this.heartsLeft,
    required this.maxHearts,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalCount > 0 ? (correctCount * 100 ~/ totalCount) : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Stat('✅', '$correctCount/$totalCount', 'câu đúng ngay'),
        const SizedBox(width: 20),
        _Stat('❤️', '$heartsLeft/$maxHearts', 'tim còn lại'),
        const SizedBox(width: 20),
        _Stat('📊', '$pct%', 'chính xác'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _Stat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
      ],
    );
  }
}
