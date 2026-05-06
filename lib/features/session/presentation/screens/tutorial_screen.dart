import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/theme/app_colors.dart';

class TutorialScreen extends StatefulWidget {
  final String skillId;
  const TutorialScreen({super.key, required this.skillId});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  List<_TutorialSlide> get _slides => _buildSlides(widget.skillId);

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_skillName(widget.skillId)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _TutorialSlideView(slide: _slides[i]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => Container(
                width: _currentPage == i ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _slides.length - 1) {
                    _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.pop();
                  }
                },
                child: Text(_currentPage < _slides.length - 1 ? 'Tiếp theo →' : 'Hiểu rồi! Làm bài'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _skillName(String skillId) {
    final key = SkillId.values.firstWhere(
      (e) => e.name == skillId,
      orElse: () => SkillId.SK01,
    );
    return skills[key]?.nameVi ?? skillId;
  }
}

class _TutorialSlide {
  final String emoji;
  final String title;
  final String explanation;
  final String example;

  const _TutorialSlide({
    required this.emoji,
    required this.title,
    required this.explanation,
    required this.example,
  });
}

class _TutorialSlideView extends StatelessWidget {
  final _TutorialSlide slide;
  const _TutorialSlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(slide.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(slide.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(slide.explanation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(slide.example,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

List<_TutorialSlide> _buildSlides(String skillId) {
  switch (skillId) {
    case 'SK01':
      return const [
        _TutorialSlide(emoji: '1️⃣', title: 'Nhận biết các số', explanation: 'Mỗi số có hình dạng riêng. Hãy quan sát thật kỹ!', example: '1  2  3  4  5\n6  7  8  9  10'),
        _TutorialSlide(emoji: '✋', title: 'Đếm bằng ngón tay', explanation: 'Giang các ngón tay ra và đếm theo từng số', example: '👆 = 1   ✌️ = 2   🤟 = 3'),
      ];
    case 'SK05':
      return const [
        _TutorialSlide(emoji: '➕', title: 'Phép cộng là gì?', explanation: 'Cộng nghĩa là gộp lại với nhau!', example: '🍎🍎 + 🍎 = 🍎🍎🍎\n  2   +   1  =   3'),
        _TutorialSlide(emoji: '🔢', title: 'Cách tính cộng', explanation: 'Bắt đầu từ số lớn hơn, đếm thêm', example: '4 + 2 = ?\nBắt đầu từ 4... 5, 6\n👉 Kết quả: 6'),
      ];
    case 'SK06':
      return const [
        _TutorialSlide(emoji: '➖', title: 'Phép trừ là gì?', explanation: 'Trừ nghĩa là bớt đi!', example: '🍎🍎🍎 - 🍎 = 🍎🍎\n   3   -  1  =   2'),
        _TutorialSlide(emoji: '🔢', title: 'Cách tính trừ', explanation: 'Bắt đầu từ số lớn, đếm ngược lại', example: '5 - 2 = ?\nBắt đầu từ 5... 4, 3\n👉 Kết quả: 3'),
      ];
    default:
      return const [
        _TutorialSlide(emoji: '💡', title: 'Mẹo hay!', explanation: 'Đọc kỹ câu hỏi và suy nghĩ thật cẩn thận.', example: 'Đừng vội vàng — đọc kỹ rồi trả lời!'),
      ];
  }
}
