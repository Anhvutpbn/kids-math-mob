import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/session_models.dart';

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

    // Fill blank
    return _FillBlankInput(
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

// ── Fill blank input ───────────────────────────────────────────────────────────

class _FillBlankInput extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSubmit;

  const _FillBlankInput({super.key, required this.enabled, required this.onSubmit});

  @override
  State<_FillBlankInput> createState() => _FillBlankInputState();
}

class _FillBlankInputState extends State<_FillBlankInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          keyboardType: TextInputType.text,
          enabled: widget.enabled,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 72, height: 72,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.primary,
          ),
          onPressed: widget.enabled && _ctrl.text.isNotEmpty
              ? () => widget.onSubmit(_ctrl.text.trim())
              : null,
          child: const Icon(Icons.check_rounded, size: 34, color: Colors.white),
        ),
      ),
    ]);
  }
}
