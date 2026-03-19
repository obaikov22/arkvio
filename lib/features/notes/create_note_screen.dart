import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../folders/folder_provider.dart';

enum _NoteType { plain, list, checklist }

class _CheckItem {
  final TextEditingController ctrl;
  bool done;

  _CheckItem({String text = '', this.done = false})
      : ctrl = TextEditingController(text: text);

  void dispose() => ctrl.dispose();
}

class CreateNoteScreen extends ConsumerStatefulWidget {
  final int? folderId;
  final int? editDocumentId;

  const CreateNoteScreen({super.key, this.folderId, this.editDocumentId});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  _NoteType _noteType = _NoteType.plain;
  final _titleCtrl = TextEditingController();
  final _plainCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  List<TextEditingController> _listCtrls = [TextEditingController()];
  List<_CheckItem> _checkItems = [_CheckItem()];
  int? _selectedFolderId;
  bool _hasDeadline = false;
  DateTime? _deadlineDate;
  int _reminderDays = 7;
  bool _saving = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedFolderId = widget.folderId;
    if (widget.editDocumentId != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocument());
    }
  }

  Future<void> _loadDocument() async {
    final db = ref.read(appDatabaseProvider);
    final doc = await db.documentsDao.getDocumentById(widget.editDocumentId!);
    if (doc == null || !mounted) return;

    setState(() {
      _titleCtrl.text = doc.title;
      _tagsCtrl.text = doc.tags;
      _selectedFolderId = doc.folderId;
      if (doc.deadlineAt != null) {
        _hasDeadline = true;
        _deadlineDate = doc.deadlineAt;
      }
      _reminderDays = doc.reminderDays;

      switch (doc.fileType) {
        case 'note':
          _noteType = _NoteType.plain;
          _plainCtrl.text = doc.content ?? '';
        case 'note_list':
          _noteType = _NoteType.list;
          final lines =
              (doc.content ?? '').split('\n').where((s) => s.isNotEmpty);
          _listCtrls = lines.isEmpty
              ? [TextEditingController()]
              : lines.map((s) => TextEditingController(text: s)).toList();
        case 'note_checklist':
          _noteType = _NoteType.checklist;
          try {
            final parsed = jsonDecode(doc.content ?? '[]') as List<dynamic>;
            _checkItems = parsed
                .map((e) => _CheckItem(
                    text: (e as Map)['t'] as String,
                    done: (e['d'] as bool?) ?? false))
                .toList();
            if (_checkItems.isEmpty) _checkItems = [_CheckItem()];
          } catch (_) {
            _checkItems = [_CheckItem()];
          }
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _plainCtrl.dispose();
    _tagsCtrl.dispose();
    for (final c in _listCtrls) {
      c.dispose();
    }
    for (final item in _checkItems) {
      item.dispose();
    }
    super.dispose();
  }

  String get _builtContent {
    return switch (_noteType) {
      _NoteType.plain => _plainCtrl.text,
      _NoteType.list => _listCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .join('\n'),
      _NoteType.checklist => jsonEncode(_checkItems
          .where((i) => i.ctrl.text.trim().isNotEmpty)
          .map((i) => {'t': i.ctrl.text.trim(), 'd': i.done})
          .toList()),
    };
  }

  String get _builtFileType {
    return switch (_noteType) {
      _NoteType.plain => 'note',
      _NoteType.list => 'note_list',
      _NoteType.checklist => 'note_checklist',
    };
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название заметки')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final content = _builtContent;
      final fileType = _builtFileType;

      if (widget.editDocumentId != null) {
        final existing =
            await db.documentsDao.getDocumentById(widget.editDocumentId!);
        if (existing != null) {
          await db.documentsDao.updateDocument(
            DocumentsCompanion(
              id: Value(existing.id),
              title: Value(title),
              filePath: Value(existing.filePath),
              fileType: Value(fileType),
              fileSizeKb: Value(0),
              folderId: Value(_selectedFolderId),
              tags: Value(_tagsCtrl.text.trim()),
              deadlineAt: Value(_hasDeadline ? _deadlineDate : null),
              reminderDays: Value(_reminderDays),
              status: Value(existing.status),
              content: Value(content),
              createdAt: Value(existing.createdAt),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      } else {
        await db.documentsDao.insertDocument(
          DocumentsCompanion(
            title: Value(title),
            filePath: const Value(''),
            fileType: Value(fileType),
            fileSizeKb: const Value(0),
            folderId: Value(_selectedFolderId),
            tags: Value(_tagsCtrl.text.trim()),
            deadlineAt: Value(_hasDeadline ? _deadlineDate : null),
            reminderDays: Value(_reminderDays),
            content: Value(content),
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  // ── List helpers ──────────────────────────────────────────────────────────

  void _addListItem() => setState(
      () => _listCtrls.add(TextEditingController()));

  void _removeListItem(int i) {
    if (_listCtrls.length <= 1) return;
    setState(() {
      _listCtrls[i].dispose();
      _listCtrls.removeAt(i);
    });
  }

  void _addCheckItem() => setState(() => _checkItems.add(_CheckItem()));

  void _removeCheckItem(int i) {
    if (_checkItems.length <= 1) return;
    setState(() {
      _checkItems[i].dispose();
      _checkItems.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final isEdit = widget.editDocumentId != null;
    final foldersAsync = ref.watch(foldersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Редактировать заметку' : 'Новая заметка',
          style: AppTextStyles.appBarTitle.copyWith(color: t.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: t.accent))
          : foldersAsync.when(
              data: (folders) => _buildForm(context, t, folders),
              loading: () =>
                  Center(child: CircularProgressIndicator(color: t.accent)),
              error: (e, _) => Center(
                  child: Text('Ошибка: $e',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: t.danger))),
            ),
    );
  }

  Widget _buildForm(
      BuildContext context, ArkvioTheme t, List<Folder> folders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Note type selector ──────────────────────────────────────────
          SegmentedButton<_NoteType>(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return t.accent;
                return t.surface;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return t.inkMuted;
              }),
            ),
            segments: const [
              ButtonSegment(
                value: _NoteType.plain,
                label: Text('Текст'),
                icon: Icon(Icons.notes),
              ),
              ButtonSegment(
                value: _NoteType.list,
                label: Text('Список'),
                icon: Icon(Icons.format_list_bulleted),
              ),
              ButtonSegment(
                value: _NoteType.checklist,
                label: Text('Чек-лист'),
                icon: Icon(Icons.checklist),
              ),
            ],
            selected: {_noteType},
            onSelectionChanged: (s) =>
                setState(() => _noteType = s.first),
          ),
          const SizedBox(height: kSpaceLG),

          // ── Title ──────────────────────────────────────────────────────
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: kSpaceLG),

          // ── Content editor ─────────────────────────────────────────────
          _buildContentEditor(t),
          const SizedBox(height: kSpaceLG),

          // ── Folder ─────────────────────────────────────────────────────
          DropdownButtonFormField<int?>(
            value: _selectedFolderId,
            style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
            decoration: const InputDecoration(labelText: 'Папка'),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Без папки',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: t.inkMuted)),
              ),
              ...folders.map(
                (f) => DropdownMenuItem<int?>(
                  value: f.id,
                  child: Text(f.name,
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: t.ink)),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _selectedFolderId = v),
          ),
          const SizedBox(height: kSpaceLG),

          // ── Tags ────────────────────────────────────────────────────────
          TextField(
            controller: _tagsCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
            decoration: InputDecoration(
              labelText: 'Теги (через запятую)',
              hintText: 'например: аудит, январь 2025',
              helperText:
                  'Теги помогут быстро найти заметку через поиск',
              helperStyle:
                  AppTextStyles.caption.copyWith(color: t.inkSubtle),
            ),
          ),
          const SizedBox(height: kSpaceLG),

          // ── Deadline ────────────────────────────────────────────────────
          SwitchListTile(
            value: _hasDeadline,
            title: Text('Установить срок',
                style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
            activeColor: t.accent,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() {
              _hasDeadline = v;
              if (v && _deadlineDate == null) {
                _deadlineDate =
                    DateTime.now().add(const Duration(days: 30));
              }
            }),
          ),
          if (_hasDeadline) ...[
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadlineDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now()
                      .add(const Duration(days: 1825)),
                  locale: const Locale('ru'),
                );
                if (picked != null) setState(() => _deadlineDate = picked);
              },
              icon: Icon(Icons.calendar_today, color: t.accent),
              label: Text(
                _deadlineDate != null
                    ? '${_deadlineDate!.day.toString().padLeft(2, '0')}.${_deadlineDate!.month.toString().padLeft(2, '0')}.${_deadlineDate!.year}'
                    : 'Выбрать дату',
                style: AppTextStyles.button.copyWith(color: t.accent),
              ),
            ),
            const SizedBox(height: kSpaceSM),
            DropdownButtonFormField<int>(
              value: _reminderDays,
              style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
              decoration:
                  const InputDecoration(labelText: 'Напомнить за'),
              items: [
                DropdownMenuItem(
                    value: 1,
                    child: Text('За 1 день',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: t.ink))),
                DropdownMenuItem(
                    value: 3,
                    child: Text('За 3 дня',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: t.ink))),
                DropdownMenuItem(
                    value: 7,
                    child: Text('За 7 дней',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: t.ink))),
              ],
              onChanged: (v) => setState(() => _reminderDays = v ?? 7),
            ),
          ],

          const SizedBox(height: kSpaceXL),

          // ── Save ────────────────────────────────────────────────────────
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: t.accent),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Сохранить',
                    style: AppTextStyles.buttonLarge
                        .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentEditor(ArkvioTheme t) {
    return switch (_noteType) {
      _NoteType.plain => TextField(
          controller: _plainCtrl,
          style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
          maxLines: 8,
          minLines: 5,
          decoration: InputDecoration(
            labelText: 'Текст заметки',
            alignLabelWithHint: true,
            hintText: 'Введите текст...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: t.inkSubtle),
          ),
        ),
      _NoteType.list => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(_listCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: kSpaceXS),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: t.inkMuted),
                    const SizedBox(width: kSpaceSM),
                    Expanded(
                      child: TextField(
                        controller: _listCtrls[i],
                        style:
                            AppTextStyles.bodyMedium.copyWith(color: t.ink),
                        decoration: InputDecoration(
                          hintText: 'Пункт ${i + 1}',
                          hintStyle: AppTextStyles.bodyMedium
                              .copyWith(color: t.inkSubtle),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_listCtrls.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            size: 18, color: t.inkMuted),
                        onPressed: () => _removeListItem(i),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: kSpaceXS),
            TextButton.icon(
              onPressed: _addListItem,
              icon: Icon(Icons.add, color: t.accent, size: 18),
              label: Text('Добавить пункт',
                  style: AppTextStyles.button.copyWith(color: t.accent)),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      _NoteType.checklist => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(_checkItems.length, (i) {
              final item = _checkItems[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: kSpaceXS),
                child: Row(
                  children: [
                    Checkbox(
                      value: item.done,
                      activeColor: t.accent,
                      onChanged: (v) =>
                          setState(() => item.done = v ?? false),
                    ),
                    Expanded(
                      child: TextField(
                        controller: item.ctrl,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: t.ink),
                        decoration: InputDecoration(
                          hintText: 'Задача ${i + 1}',
                          hintStyle: AppTextStyles.bodyMedium
                              .copyWith(color: t.inkSubtle),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_checkItems.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            size: 18, color: t.inkMuted),
                        onPressed: () => _removeCheckItem(i),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: kSpaceXS),
            TextButton.icon(
              onPressed: _addCheckItem,
              icon: Icon(Icons.add, color: t.accent, size: 18),
              label: Text('Добавить задачу',
                  style: AppTextStyles.button.copyWith(color: t.accent)),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
    };
  }
}
