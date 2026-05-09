import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../../../shared/widgets/mute_button.dart';

const _tableColors = [
  Color(0xFFFF7043), // 2 — deep orange
  Color(0xFF43A047), // 3 — green
  Color(0xFF1E88E5), // 4 — blue
  Color(0xFF8E24AA), // 5 — purple
  Color(0xFF00897B), // 6 — teal
  Color(0xFFE91E8C), // 7 — pink
  Color(0xFFF57C00), // 8 — orange
  Color(0xFF3949AB), // 9 — indigo
];

const _tableEmojis = ['🐣', '🌱', '🚀', '⭐', '🦋', '🎯', '🔥', '👑'];

class MultiplicationLearnScreen extends ConsumerStatefulWidget {
  const MultiplicationLearnScreen({super.key});

  @override
  ConsumerState<MultiplicationLearnScreen> createState() =>
      _MultiplicationLearnScreenState();
}

class _MultiplicationLearnScreenState
    extends ConsumerState<MultiplicationLearnScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _speakTable(int tableNum) {
    final muted = ref.read(muteProvider);
    final tts = ref.read(ttsHelperProvider);
    tts.speak('Bảng nhân $tableNum', muted: muted);
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      '📖 Học Bảng Cửu Chương',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                  ),
                  const MuteButton(),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Dot indicator
            _DotIndicator(current: _currentPage, total: 8),
            const SizedBox(height: 8),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 8,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _speakTable(i + 2);
                },
                itemBuilder: (_, i) => _TableSlide(tableNum: i + 2, index: i),
              ),
            ),
            // Navigation buttons
            _NavBar(
              currentPage: _currentPage,
              onPrev: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
              onNext: _currentPage < 7 ? () => _goTo(_currentPage + 1) : null,
              onDone: _currentPage == 7 ? () => context.pop() : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TableSlide extends StatelessWidget {
  final int tableNum;
  final int index;

  const _TableSlide({required this.tableNum, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = _tableColors[index];
    final emoji = _tableEmojis[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Title
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 4),
            Text(
              'Bảng Nhân $tableNum',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Equations list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: 10,
                itemBuilder: (_, i) {
                  final multiplier = i + 1;
                  final result = tableNum * multiplier;
                  final isEven = i.isEven;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isEven
                          ? Colors.white.withOpacity(0.25)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Multiplier badge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$multiplier',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Equation
                        Expanded(
                          child: Text(
                            '$tableNum  ×  $multiplier',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Separator
                        const Text(
                          '=',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Result
                        Text(
                          '$result',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _DotIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final color = _tableColors[i];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onDone;

  const _NavBar({
    required this.currentPage,
    this.onPrev,
    this.onNext,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          // Prev
          _NavButton(
            icon: Icons.arrow_back_rounded,
            label: 'Trước',
            onTap: onPrev,
            filled: false,
          ),
          const SizedBox(width: 12),
          // Page label
          Expanded(
            child: Text(
              'Bảng ${currentPage + 2} / 9',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next or Done
          onDone != null
              ? _NavButton(
                  icon: Icons.check_rounded,
                  label: 'Xong',
                  onTap: onDone,
                  filled: true,
                  color: const Color(0xFF43A047),
                )
              : _NavButton(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Tiếp',
                  onTap: onNext,
                  filled: true,
                ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final Color? color;

  const _NavButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.filled = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFFE65100);
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: filled
                ? (enabled ? activeColor : Colors.grey)
                : Colors.transparent,
            border: filled
                ? null
                : Border.all(
                    color: enabled ? activeColor : Colors.grey,
                    width: 2,
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: filled
                ? [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(icon, color: Colors.white, size: 20),
                  ]
                : [
                    Icon(icon, color: activeColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
