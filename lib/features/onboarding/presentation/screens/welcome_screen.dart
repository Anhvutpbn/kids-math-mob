import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/onboarding_data_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _nameCtrl = TextEditingController();
  int _selectedAge = 5;
  String _selectedLanguage = 'vi';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy nhập tên bé nhé!')),
      );
      return;
    }
    ref.read(onboardingDataProvider.notifier).update((s) => s.copyWith(
      childName: _nameCtrl.text.trim(),
      childAge: _selectedAge,
      language: _selectedLanguage,
    ));
    context.push('/onboarding/avatar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text('👋', style: const TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 24),
              Text('Xin chào!',
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('Hãy cho chúng tôi biết về bé nhé',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textLight)),
              const SizedBox(height: 40),
              Text('Tên của bé là gì?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Minh',
                  prefixIcon: Icon(Icons.child_care, color: AppColors.primary),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 32),
              Text('Bé bao nhiêu tuổi?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [5, 6, 7].map((age) => _AgeButton(
                  age: age,
                  selected: _selectedAge == age,
                  onTap: () => setState(() => _selectedAge = age),
                )).toList(),
              ),
              const SizedBox(height: 32),
              Text('Ngôn ngữ học', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  _LangButton(label: '🇻🇳  Tiếng Việt', value: 'vi', selected: _selectedLanguage == 'vi',
                      onTap: () => setState(() => _selectedLanguage = 'vi')),
                  const SizedBox(width: 12),
                  _LangButton(label: '🇬🇧  English', value: 'en', selected: _selectedLanguage == 'en',
                      onTap: () => setState(() => _selectedLanguage = 'en')),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _next,
                child: const Text('Tiếp tục →'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textDark,
            )),
          ),
        ),
      ),
    );
  }
}

class _AgeButton extends StatelessWidget {
  final int age;
  final bool selected;
  final VoidCallback onTap;

  const _AgeButton({required this.age, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$age', style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textDark,
            )),
            Text('tuổi', style: TextStyle(
              fontSize: 14,
              color: selected ? Colors.white70 : AppColors.textLight,
            )),
          ],
        ),
      ),
    );
  }
}
