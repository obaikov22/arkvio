import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/whats_new_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ещё',
            style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader('Данные'),
          ListTile(
            leading: Icon(Icons.archive_outlined, color: t.accent),
            title: Text('Создать резервную копию',
                style: AppTextStyles.tileName.copyWith(color: t.ink)),
            subtitle: Text('Сохранить все файлы и базу данных',
                style: AppTextStyles.tileSubtitle.copyWith(color: t.inkMuted)),
            onTap: () async {
              try {
                await BackupService.shareBackup();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            },
          ),
          Divider(height: 1, color: t.border),
          _SectionHeader('О приложении'),
          ListTile(
            leading: Icon(Icons.auto_awesome_outlined, color: t.accent),
            title: Text(
              'Что нового в версии ${WhatsNewService.currentVersion}',
              style: AppTextStyles.tileName.copyWith(color: t.ink),
            ),
            trailing: Icon(Icons.chevron_right, size: 18, color: t.inkSubtle),
            onTap: () => context.push('/whats_new'),
          ),
          Divider(height: 1, color: t.border),
          ListTile(
            leading: Icon(Icons.info_outline, color: t.inkMuted),
            title: Text('Arkvio',
                style: AppTextStyles.tileName.copyWith(color: t.ink)),
            subtitle: Text('Версия 1.0.0',
                style:
                    AppTextStyles.tileSubtitle.copyWith(color: t.inkMuted)),
          ),
          ListTile(
            leading: Icon(Icons.storage_outlined, color: t.inkMuted),
            title: Text('Хранилище',
                style: AppTextStyles.tileName.copyWith(color: t.ink)),
            subtitle: Text('Все данные хранятся локально на устройстве',
                style:
                    AppTextStyles.tileSubtitle.copyWith(color: t.inkMuted)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          kSpaceLG, kSpaceLG, kSpaceLG, kSpaceXS),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionHeader.copyWith(color: t.accent),
      ),
    );
  }
}
