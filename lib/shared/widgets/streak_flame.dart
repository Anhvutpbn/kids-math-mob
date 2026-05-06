import 'package:flutter/material.dart';

/// Animated streak flame — pulses when streak > 0.
class StreakFlame extends StatefulWidget {
  final int streak;
  final double size;
  const StreakFlame({super.key, required this.streak, this.size = 36});

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.streak > 0) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakFlame old) {
    super.didUpdateWidget(old);
    if (widget.streak > 0 && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (widget.streak == 0) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Text(
        widget.streak > 0 ? '🔥' : '💤',
        style: TextStyle(fontSize: widget.size),
      ),
    );
  }
}
