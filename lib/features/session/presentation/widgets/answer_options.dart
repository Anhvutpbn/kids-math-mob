import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/session_models.dart';
import '../../../multiplication/presentation/widgets/number_pad.dart';

class AnswerOptions extends StatefulWidget {
  final SessionQuestion question;
  final ValueChanged<String> onAnswer;
  final bool enabled;

  const AnswerOptions({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.enabled,
  });

  @override
  State<AnswerOptions> createState() => _AnswerOptionsState();
}

class _AnswerOptionsState extends State<AnswerOptions> {
  String? _selected;

  @override
  void didUpdateWidget(AnswerOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.type == 'min_max') {
      return _MinMaxSelector(
        key: ValueKey(widget.question.id),
        options: widget.question.options,
        selected: _selected,
        enabled: widget.enabled,
        onAnswer: (v) {
          setState(() => _selected = v);
          widget.onAnswer(v);
        },
      );
    }

    if (widget.question.type == 'multiple_choice') {
      return Column(
        children: widget.question.options.map((opt) {
          final isSelected = _selected == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SizedBox(
              width: double.infinity,
              height: 76,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.primary : Colors.white,
                  foregroundColor: isSelected ? Colors.white : AppColors.textDark,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 2.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: isSelected ? 6 : 2,
                ),
                onPressed: widget.enabled
                    ? () {
                        setState(() => _selected = opt);
                        widget.onAnswer(opt);
                      }
                    : null,
                child: Text(opt, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Fill blank → NumberPad (SK05, SK06, SK07)
    return _NumberPadInput(
      key: ValueKey(widget.question.id),
      enabled: widget.enabled,
      onSubmit: widget.onAnswer,
    );
  }
}

// ── Min/Max selector — colorful number squares ────────────────────────────────

const _squareColors = [
  Color(0xFFE53935), // red
  Color(0xFF1E88E5), // blue
  Color(0xFF43A047), // green
  Color(0xFFFB8C00), // orange
  Color(0xFF8E24AA), // purple
  Color(0xFF00ACC1), // teal
  Color(0xFFFFB300), // amber
  Color(0xFFD81B60), // pink
  Color(0xFF558B2F), // dark green
];

class _MinMaxSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onAnswer;

  const _MinMaxSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final color = _squareColors[i % _squareColors.length];
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: enabled ? () => onAnswer(opt) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.5 : 0.35),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? color : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── NumberPad input (SK05 cộng, SK06 trừ, SK07 điền số) ──────────────────────

class _NumberPadInput extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSubmit;

  const _NumberPadInput({super.key, required this.enabled, required this.onSubmit});

  @override
  State<_NumberPadInput> createState() => _NumberPadInputState();
}

class _NumberPadInputState extends State<_NumberPadInput> {
  String _input = '';

  @override
  void didUpdateWidget(_NumberPadInput old) {
    super.didUpdateWidget(old);
    // Clear input when feedback dismisses (enabled flips false→true = retry same question)
    if (!old.enabled && widget.enabled) {
      setState(() => _input = '');
    }
  }

  void _appendDigit(String d) {
    if (_input.length >= 3) return;
    setState(() => _input += d);
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _confirm() {
    if (_input.isEmpty) return;
    widget.onSubmit(_input);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputDisplay(input: _input),
        const SizedBox(height: 12),
        Expanded(
          child: NumberPad(
            onDigit: _appendDigit,
            onBackspace: _backspace,
            onConfirm: _input.isEmpty ? null : _confirm,
            enabled: widget.enabled,
          ),
        ),
      ],
    );
  }
}

class _InputDisplay extends StatelessWidget {
  final String input;
  const _InputDisplay({required this.input});

  @override
  Widget build(BuildContext context) {
    final hasInput = input.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasInput
              ? AppColors.primary.withOpacity(0.6)
              : Colors.grey.shade300,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          hasInput ? input : 'Nhập đáp án...',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: hasInput ? AppColors.textDark : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
