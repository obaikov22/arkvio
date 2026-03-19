import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/whats_new_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    kSpaceLG, kSpaceXXL, kSpaceLG, kSpaceLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Что нового',
                      style: AppTextStyles.display.copyWith(color: t.ink),
                    ),
                    const SizedBox(height: kSpaceXS),
                    Text(
                      'Версия ${WhatsNewService.currentVersion}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: t.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: kSpaceLG),
                    Divider(height: 1, color: t.border),
                    const SizedBox(height: kSpaceXL),
                    ..._features.asMap().entries.map(
                          (e) => _FeatureTile(item: e.value, index: e.key),
                        ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  kSpaceLG, kSpaceSM, kSpaceLG, kSpaceXL),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    await WhatsNewService.markSeen();
                    if (context.mounted) context.go('/');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: t.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusLG),
                    ),
                  ),
                  child: Text(
                    'Отлично!',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsNewItem {
  final String emoji;
  final String title;
  final String description;

  const _WhatsNewItem({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

// ← UPDATE THIS LIST every release
const _features = [
  _WhatsNewItem(
    emoji: '📅',
    title: 'Календарь',
    description:
        'Новая вкладка с календарём. Переключайтесь между личными заметками и документами — всё сразу видно по датам.',
  ),
  _WhatsNewItem(
    emoji: '🗒️',
    title: 'Личные заметки по датам',
    description:
        'Создавайте короткие заметки на любой день прямо в календаре. Удобно фиксировать встречи, задачи и напоминания.',
  ),
  _WhatsNewItem(
    emoji: '📋',
    title: 'История заметок за месяц',
    description:
        'Все заметки месяца собраны в одном списке: сегодняшние сверху, будущие — следом, прошедшие — в конце.',
  ),
  _WhatsNewItem(
    emoji: '📂',
    title: 'Документы в календаре',
    description:
        'Режим «Документы» показывает, какие файлы были добавлены в Arkvio в выбранный день. Удобно для контроля.',
  ),
];

class _FeatureTile extends StatefulWidget {
  final _WhatsNewItem item;
  final int index;

  const _FeatureTile({required this.item, required this.index});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: kSpaceMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t.accentLight,
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                child: Center(
                  child: Text(
                    widget.item.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: kSpaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      widget.item.title,
                      style: AppTextStyles.tileName.copyWith(
                        color: t.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.item.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: t.inkMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
