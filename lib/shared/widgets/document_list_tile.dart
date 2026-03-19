import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../utils/file_utils.dart';
import '../utils/date_utils.dart' as du;
import 'file_type_badge.dart';

const _monthsRu = [
  'янв', 'фев', 'мар', 'апр', 'май', 'июн',
  'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
];

class DocumentListTile extends StatelessWidget {
  final Document document;

  const DocumentListTile({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final deadline = document.deadlineAt;
    final urgency = du.getDeadlineUrgency(deadline);
    final isUrgent = urgency == du.DeadlineUrgency.urgent;

    final dateStr =
        '${document.createdAt.day} ${_monthsRu[document.createdAt.month - 1]}';
    final isNote = document.fileType.startsWith('note');
    final subtitle = isNote
        ? '${fileTypeLabel(document.fileType)} · $dateStr'
        : '${formatFileSize(document.fileSizeKb)} · ${fileTypeLabel(document.fileType)} · $dateStr';

    Widget badge;
    if (deadline != null && isUrgent) {
      badge = _Chip(
        text: du.formatDeadlineShort(deadline),
        bg: t.urgentLight,
        fg: t.urgent,
      );
    } else if (deadline != null) {
      badge = _Chip(
        text: du.formatDeadlineShort(deadline),
        bg: t.accentLight,
        fg: t.accent,
      );
    } else {
      badge = _Chip(text: 'Актив', bg: t.accentLight, fg: t.accent);
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: t.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: t.accentLight,
        highlightColor: t.accentLight.withValues(alpha: 0.5),
        onTap: () => context.push('/document/${document.id}'),
        child: Padding(
          padding: const EdgeInsets.all(kSpaceMD),
          child: Row(
            children: [
              FileTypeBadge(fileType: document.fileType),
              const SizedBox(width: kSpaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: AppTextStyles.tileName.copyWith(color: t.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          AppTextStyles.tileSubtitle.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: kSpaceSM),
              badge,
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: kSpaceSM, vertical: kSpaceXS),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: fg),
      ),
    );
  }
}
