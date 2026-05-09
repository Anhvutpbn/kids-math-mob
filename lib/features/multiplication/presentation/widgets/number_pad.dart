import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberPad extends StatelessWidget {
  final VoidCallback? onConfirm;
  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onConfirm,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(['1', '2', '3']),
        const SizedBox(height: 10),
        _row(['4', '5', '6']),
        const SizedBox(height: 10),
        _row(['7', '8', '9']),
        const SizedBox(height: 10),
        _bottomRow(),
      ],
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _DigitButton(
                    label: d,
                    onTap: enabled ? () => onDigit(d) : null,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _bottomRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _BackspaceButton(
              onTap: enabled ? onBackspace : null,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _DigitButton(
              label: '0',
              onTap: enabled ? () => onDigit('0') : null,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _ConfirmButton(
              onTap: enabled ? onConfirm : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _DigitButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _BackspaceButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE0B2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: const Center(
          child: Icon(Icons.backspace_rounded, size: 26, color: Color(0xFFE65100)),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ConfirmButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.mediumImpact();
          onTap!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 66,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? const [
                  BoxShadow(color: Color(0x442E7D32), blurRadius: 8, offset: Offset(0, 3)),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_rounded,
                size: 24,
                color: active ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: active ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
