import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'deadlines_provider.dart';

class DeadlinesScreen extends ConsumerWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    final docsAsync = ref.watch(documentsWithDeadlinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Сроки',
            style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: docsAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: t.accent)),
        error: (e, _) => Center(
            child: Text('Ошибка: $e',
                style: AppTextStyles.bodyMedium.copyWith(color: t.danger))),
        data: (docs) {
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(kSpaceXXL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_outlined, size: 48, color: t.inkSubtle),
                    const SizedBox(height: kSpaceLG),
                    Text(
                      'Нет документов с дедлайнами',
                      style:
                          AppTextStyles.titleMedium.copyWith(color: t.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpaceSM),
                    Text(
                      'При загрузке файла установите срок,\nи он появится здесь',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: t.inkSubtle),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final now = DateTime.now();
          final overdue =
              docs.where((d) => d.deadlineAt!.isBefore(now)).toList();
          final urgent = docs.where((d) {
            final days = d.deadlineAt!.difference(now).inDays;
            return days >= 0 && days <= 14;
          }).toList();
          final upcoming = docs.where((d) {
            final days = d.deadlineAt!.difference(now).inDays;
            return days > 14;
          }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: kSpaceMD, vertical: kSpaceSM),
            children: [
              if (overdue.isNotEmpty) ...[
                _SectionHeader(title: 'Просрочено', color: t.danger),
                ...overdue.map((d) => _DeadlineTile(document: d)),
                const SizedBox(height: kSpaceMD),
              ],
              if (urgent.isNotEmpty) ...[
                _SectionHeader(title: 'Скоро — до 14 дней', color: t.urgent),
                ...urgent.map((d) => _DeadlineTile(document: d)),
                const SizedBox(height: kSpaceMD),
              ],
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: 'Предстоящие', color: t.accent),
                ...upcoming.map((d) => _DeadlineTile(document: d)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          kSpaceXS, kSpaceXS, kSpaceXS, kSpaceSM),
      child: Text(
        title,
        style: AppTextStyles.sectionHeader.copyWith(color: color),
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final Document document;
  const _DeadlineTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final now = DateTime.now();
    final deadline = document.deadlineAt!;
    final daysLeft = deadline.difference(now).inDays;
    final isOverdue = deadline.isBefore(now);

    final Color barColor;
    final String daysLabel;
    if (isOverdue) {
      barColor = t.danger;
      daysLabel = 'Просрочено';
    } else if (daysLeft == 0) {
      barColor = t.danger;
      daysLabel = 'Сегодня';
    } else if (daysLeft == 1) {
      barColor = t.danger;
      daysLabel = 'Завтра';
    } else if (daysLeft <= 14) {
      barColor = t.urgent;
      daysLabel = '$daysLeft дн.';
    } else {
      barColor = t.accent;
      daysLabel = '$daysLeft дн.';
    }

    final dateFormatted = DateFormat('d MMM yyyy', 'ru').format(deadline);

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpaceSM),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusLG),
          side: BorderSide(color: t.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => GoRouter.of(context).push('/document/${document.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kSpaceMD, vertical: kSpaceMD),
            child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 44,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: kSpaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style:
                              AppTextStyles.tileName.copyWith(color: t.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Срок: $dateFormatted',
                          style: AppTextStyles.tileSubtitle
                              .copyWith(color: t.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: kSpaceSM),
                  Text(
                    daysLabel,
                    style: AppTextStyles.label.copyWith(
                      color: barColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
