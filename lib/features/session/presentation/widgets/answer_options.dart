import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/session_models.dart';
import '../../../multiplication/presentation/widgets/number_pad.dart';

class AnswerOptions extends StatefulWidget {
  final SessionQuestion question;
  final ValueChanged<String> onAnswer;
  final bool enabled;
  final bool showHints;

  const AnswerOptions({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.enabled,
    this.showHints = true,
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
    if (widget.question.type == 'vertical_arithmetic') {
      return _VerticalArithInput(
        key: ValueKey(widget.question.id),
        options: widget.question.options,
        enabled: widget.enabled,
        showHints: widget.showHints,
        onSubmit: widget.onAnswer,
      );
    }

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
      final options = widget.question.options;
      const labels = ['A', 'B', 'C', 'D'];
      final List<Widget> children = [];

      for (int i = 0; i < options.length; i++) {
        final opt = options[i];
        final color = _palette[i % _palette.length];
        final label = i < labels.length ? labels[i] : '${i + 1}';
        final isSel = _selected == opt;

        children.add(Expanded(
          child: _BounceCard(
            onTap: widget.enabled
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() => _selected = opt);
                    widget.onAnswer(opt);
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSel ? color : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSel ? color : Colors.grey.shade200,
                  width: isSel ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSel
                        ? color.withOpacity(0.35)
                        : Colors.black.withOpacity(0.07),
                    blurRadius: isSel ? 14 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Centered answer text
                  Text(
                    opt,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: isSel ? Colors.white : const Color(0xFF1A237E),
                    ),
                  ),
                  // Letter badge — left side
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSel
                              ? Colors.white.withOpacity(0.3)
                              : color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isSel ? Colors.white : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Check icon — right side when selected
                  if (isSel)
                    const Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));

        if (i < options.length - 1) children.add(const SizedBox(height: 10));
      }
      return Column(children: children);
    }

    // fill_blank → NumberPad (SK05, SK06, SK07)
    return _NumberPadInput(
      key: ValueKey(widget.question.id),
      enabled: widget.enabled,
      onSubmit: widget.onAnswer,
    );
  }
}

const _palette = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
];

const _squareColors = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFF00ACC1),
  Color(0xFFFFB300),
  Color(0xFFD81B60),
  Color(0xFF558B2F),
];

// ── Bounce animation wrapper ──────────────────────────────────────────────────

class _BounceCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _BounceCard({required this.child, this.onTap});

  @override
  State<_BounceCard> createState() => _BounceCardState();
}

class _BounceCardState extends State<_BounceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.06), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.onTap == null) return;
    _ctrl.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ── Min/Max selector ─────────────────────────────────────────────────────────

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

  static const _spacing = 12.0;

  int get _cols => options.length <= 4 ? 2 : 3;
  int get _rows => (options.length / _cols).ceil();

  Widget _square(String opt, int i, double height) {
    final color = _squareColors[i % _squareColors.length];
    final isSel = selected == opt;
    return _BounceCard(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onAnswer(opt);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        decoration: BoxDecoration(
          color: isSel ? Colors.white : color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSel ? color : Colors.transparent,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isSel ? 0.5 : 0.35),
              blurRadius: isSel ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            opt,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: isSel ? color : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final squareH = constraints.maxHeight.isFinite
          ? ((constraints.maxHeight - _spacing * (_rows - 1)) / _rows)
              .clamp(72.0, 140.0)
          : 100.0;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_rows, (r) {
          final start = r * _cols;
          final rowItems = <Widget>[];
          for (int c = 0; c < _cols; c++) {
            if (c > 0) rowItems.add(const SizedBox(width: _spacing));
            final i = start + c;
            rowItems.add(Expanded(
              child: i < options.length
                  ? _square(options[i], i, squareH)
                  : SizedBox(height: squareH),
            ));
          }
          return Padding(
            padding: EdgeInsets.only(top: r > 0 ? _spacing : 0),
            child: Row(children: rowItems),
          );
        }),
      );
    });
  }
}

// ── NumberPad input (SK05, SK06, SK07) ────────────────────────────────────────

class _NumberPadInput extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSubmit;

  const _NumberPadInput(
      {super.key, required this.enabled, required this.onSubmit});

  @override
  State<_NumberPadInput> createState() => _NumberPadInputState();
}

class _NumberPadInputState extends State<_NumberPadInput> {
  String _input = '';

  @override
  void didUpdateWidget(_NumberPadInput old) {
    super.didUpdateWidget(old);
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

// ── Vertical arithmetic input: input display + hint 2×2 + numberpad ──────────

class _VerticalArithInput extends StatefulWidget {
  final List<String> options;
  final bool enabled;
  final bool showHints;
  final ValueChanged<String> onSubmit;

  const _VerticalArithInput({
    super.key,
    required this.options,
    required this.enabled,
    required this.showHints,
    required this.onSubmit,
  });

  @override
  State<_VerticalArithInput> createState() => _VerticalArithInputState();
}

class _VerticalArithInputState extends State<_VerticalArithInput> {
  String _input = '';
  String? _selectedHint;

  @override
  void didUpdateWidget(_VerticalArithInput old) {
    super.didUpdateWidget(old);
    if (!old.enabled && widget.enabled) {
      setState(() { _input = ''; _selectedHint = null; });
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

  void _pickHint(String v) {
    HapticFeedback.lightImpact();
    setState(() { _input = v; _selectedHint = v; });
    widget.onSubmit(v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputDisplay(input: _input),
        if (widget.showHints && widget.options.isNotEmpty) ...[
          const SizedBox(height: 10),
          _HintButtons(
            options: widget.options,
            selected: _selectedHint,
            enabled: widget.enabled,
            onSelect: _pickHint,
          ),
        ],
        const SizedBox(height: 10),
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

// ── 2×2 hint option buttons ───────────────────────────────────────────────────

const _hintPalette = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
];

class _HintButtons extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelect;

  const _HintButtons({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = options.take(4).toList();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: List.generate(items.length, (i) {
        final opt = items[i];
        final color = _hintPalette[i % _hintPalette.length];
        final isSel = selected == opt;
        return _BounceCard(
          onTap: enabled ? () => onSelect(opt) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSel ? Colors.white : color,
              borderRadius: BorderRadius.circular(18),
              border: isSel ? Border.all(color: color, width: 3) : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSel ? 0.45 : 0.3),
                  blurRadius: isSel ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isSel ? color : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
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
              : Colors.grey.shade200,
          width: 2,
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
            color: hasInput ? const Color(0xFF1A237E) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
