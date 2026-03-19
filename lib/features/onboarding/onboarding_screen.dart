import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.folder_open_outlined,
      title: 'Все документы в одном месте',
      subtitle:
          'Храните договоры, акты, счета и сканы прямо на телефоне. Без облака — всё локально.',
    ),
    _OnboardingPage(
      icon: Icons.search_outlined,
      title: 'Найдите любой документ за секунду',
      subtitle:
          'Поиск работает по тексту внутри файлов. Введите ИНН, название компании или сумму.',
    ),
    _OnboardingPage(
      icon: Icons.schedule_outlined,
      title: 'Не пропустите важный срок',
      subtitle:
          'Установите дедлайн для документа — Arkvio напомнит за несколько дней.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Пропустить',
                    style: AppTextStyles.button.copyWith(color: t.inkMuted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: kSpaceXS),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? t.accent
                        : t.accent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(kSpaceXS),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kSpaceXXL),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpaceXL),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: t.accent),
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    isLast ? 'Начать' : 'Далее',
                    style: AppTextStyles.buttonLarge
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kSpaceXXL),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: t.accentLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: t.accent),
          ),
          const SizedBox(height: kSpaceXXL),
          Text(
            title,
            style: AppTextStyles.onboardingTitle.copyWith(color: t.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpaceLG),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: t.inkMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
