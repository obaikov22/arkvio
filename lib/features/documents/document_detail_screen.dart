import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/services/file_manager_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/utils/date_utils.dart' as du;
import '../../shared/utils/file_utils.dart';
import '../../shared/widgets/file_type_badge.dart';
import '../folders/folder_provider.dart';
import 'documents_provider.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final int documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    final docAsync = ref.watch(documentByIdProvider(documentId));

    return docAsync.when(
      data: (doc) {
        if (doc == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Документ',
                  style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
            ),
            body: Center(
              child: Text('Документ не найден',
                  style: AppTextStyles.bodyMedium.copyWith(color: t.inkMuted)),
            ),
          );
        }
        return _DocumentDetailView(document: doc);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('Загрузка...',
              style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        ),
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text('Ошибка',
              style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        ),
        body: Center(
            child: Text('$e',
                style: AppTextStyles.bodyMedium.copyWith(color: t.danger))),
      ),
    );
  }
}

class _DocumentDetailView extends ConsumerWidget {
  final Document document;

  const _DocumentDetailView({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    final isNote = document.fileType.startsWith('note');
    final folderAsync = document.folderId != null
        ? ref.watch(folderByIdProvider(document.folderId!))
        : const AsyncData<Folder?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          document.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.appBarTitle.copyWith(color: t.ink),
        ),
        actions: [
          if (isNote)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: t.inkMuted),
              onPressed: () =>
                  context.push('/create-note?editId=${document.id}'),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: t.inkMuted),
            onPressed: () => _confirmDelete(context, ref, t),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kSpaceLG),
        children: [
          if (isNote) ...[
            _buildNoteContent(context, ref, document, t),
            const SizedBox(height: kSpaceLG),
          ],
          _InfoCard(
            children: [
              if (!isNote)
                _InfoRow(
                  label: 'Тип файла',
                  child: FileTypeBadge(fileType: document.fileType),
                ),
              if (!isNote)
                _InfoRow(
                  label: 'Размер',
                  value: formatFileSize(document.fileSizeKb),
                ),
              if (isNote)
                _InfoRow(
                    label: 'Тип', value: _noteTypeLabel(document.fileType)),
              _InfoRow(
                label: 'Папка',
                child: folderAsync.when(
                  data: (f) => Text(f?.name ?? 'Без папки',
                      style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
                  loading: () => SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: t.accent),
                  ),
                  error: (_, __) => Text('—',
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: t.inkMuted)),
                ),
              ),
              if (document.tags.isNotEmpty)
                _InfoRow(label: 'Теги', value: document.tags),
              _InfoRow(
                label: 'Дедлайн',
                child: document.deadlineAt != null
                    ? Text(
                        du.formatDate(document.deadlineAt!),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              du.deadlineColor(document.deadlineAt, context),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text('Не установлен',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: t.inkMuted)),
              ),
              _InfoRow(
                label: 'Добавлен',
                value: du.formatDate(document.createdAt),
              ),
            ],
          ),
          const SizedBox(height: kSpaceLG),

          if (document.filePath.isNotEmpty)
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: t.accent),
              onPressed: () => _openFile(context),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: Text('Открыть файл',
                  style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),

          if (document.deadlineAt == null) ...[
            const SizedBox(height: kSpaceSM),
            OutlinedButton.icon(
              onPressed: () => _setDeadline(context, ref),
              icon: Icon(Icons.calendar_today, color: t.accent),
              label: Text('Установить срок',
                  style: AppTextStyles.button.copyWith(color: t.accent)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteContent(
      BuildContext context, WidgetRef ref, Document doc, ArkvioTheme t) {
    final content = doc.content ?? '';

    Widget body;
    if (doc.fileType == 'note_checklist') {
      final items = content.isEmpty
          ? <Map<String, dynamic>>[]
          : (jsonDecode(content) as List).cast<Map<String, dynamic>>();
      body = Column(
        children: [
          for (int i = 0; i < items.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: items[i]['d'] as bool? ?? false,
                  onChanged: (v) =>
                      _toggleChecklistItem(ref, doc, i, v ?? false),
                  activeColor: t.accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: Text(
                    items[i]['t'] as String? ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: (items[i]['d'] as bool? ?? false)
                          ? t.inkMuted
                          : t.ink,
                      decoration: (items[i]['d'] as bool? ?? false)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    } else if (doc.fileType == 'note_list') {
      final lines = content.split('\n').where((l) => l.isNotEmpty).toList();
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: t.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(line,
                        style:
                            AppTextStyles.bodyMedium.copyWith(color: t.ink)),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      body = SelectableText(
        content,
        style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
      );
    }

    return _InfoCard(children: [body]);
  }

  Future<void> _toggleChecklistItem(
      WidgetRef ref, Document doc, int index, bool value) async {
    final items = (jsonDecode(doc.content!) as List)
        .cast<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    items[index] = {'t': items[index]['t'], 'd': value};
    await ref.read(appDatabaseProvider).documentsDao.updateDocument(
          DocumentsCompanion(
            id: Value(doc.id),
            content: Value(jsonEncode(items)),
            title: Value(doc.title),
            filePath: Value(doc.filePath),
            fileType: Value(doc.fileType),
            fileSizeKb: Value(doc.fileSizeKb),
            folderId: Value(doc.folderId),
            tags: Value(doc.tags),
            deadlineAt: Value(doc.deadlineAt),
            reminderDays: Value(doc.reminderDays),
            status: Value(doc.status),
            createdAt: Value(doc.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  String _noteTypeLabel(String fileType) => switch (fileType) {
        'note' => 'Текстовая заметка',
        'note_list' => 'Список',
        'note_checklist' => 'Чек-лист',
        _ => 'Заметка',
      };

  Future<void> _openFile(BuildContext context) async {
    if (document.filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл недоступен (демо-данные)')),
      );
      return;
    }
    final result = await OpenFile.open(document.filePath);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Не удалось открыть файл: ${result.message}')),
      );
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ArkvioTheme t) {
    final isNote = document.fileType.startsWith('note');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text(
          isNote ? 'Удалить заметку?' : 'Удалить документ?',
          style: AppTextStyles.titleMedium.copyWith(color: t.ink),
        ),
        content: Text(
          isNote
              ? 'Заметка будет удалена. Это действие необратимо.'
              : 'Файл будет удалён с устройства. Это действие необратимо.',
          style: AppTextStyles.bodyMedium.copyWith(color: t.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена',
                style: AppTextStyles.button.copyWith(color: t.inkMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: t.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await FileManagerService.deleteFile(document.filePath);
              final db = ref.read(appDatabaseProvider);
              await db.documentsDao.deleteDocument(document.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Удалить',
                style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _setDeadline(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
      locale: const Locale('ru'),
    );
    if (picked != null) {
      final db = ref.read(appDatabaseProvider);
      await db.documentsDao.updateDocument(
        DocumentsCompanion(
          id: Value(document.id),
          title: Value(document.title),
          filePath: Value(document.filePath),
          fileType: Value(document.fileType),
          fileSizeKb: Value(document.fileSizeKb),
          content: Value(document.content),
          folderId: Value(document.folderId),
          tags: Value(document.tags),
          deadlineAt: Value(picked),
          reminderDays: Value(document.reminderDays),
          status: Value(document.status),
          createdAt: Value(document.createdAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(kRadiusLG),
        border: Border.all(color: t.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _InfoRow({required this.label, this.value, this.child});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpaceSM - 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: t.inkMuted),
            ),
          ),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: child ??
                Text(value ?? '—',
                    style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
          ),
        ],
      ),
    );
  }
}
