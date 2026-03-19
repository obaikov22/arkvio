import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import '../../core/database/app_database.dart';
import '../../core/services/file_manager_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../folders/folder_provider.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final int? folderId;

  const DocumentUploadScreen({super.key, this.folderId});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  String? _pickedFilePath;
  String? _pickedFileName;
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  int? _selectedFolderId;
  bool _hasDeadline = false;
  DateTime? _deadlineDate;
  int _reminderDays = 7;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedFolderId = widget.folderId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'
      ],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      setState(() {
        _pickedFilePath = path;
        _pickedFileName = name;
        if (_titleCtrl.text.isEmpty) {
          _titleCtrl.text = p.basenameWithoutExtension(name);
        }
      });
    }
  }

  Future<void> _save() async {
    if (_pickedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите файл')),
      );
      return;
    }
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final importedPath =
          await FileManagerService.importFile(_pickedFilePath!);
      final sizeKb = FileManagerService.getFileSizeKb(importedPath);
      final fileType = FileManagerService.getFileType(importedPath);

      final db = ref.read(appDatabaseProvider);
      await db.documentsDao.insertDocument(
        DocumentsCompanion(
          title: Value(title),
          filePath: Value(importedPath),
          fileType: Value(fileType),
          fileSizeKb: Value(sizeKb),
          folderId: Value(_selectedFolderId),
          tags: Value(_tagsCtrl.text.trim()),
          deadlineAt: Value(_hasDeadline ? _deadlineDate : null),
          reminderDays: Value(_reminderDays),
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final foldersAsync = ref.watch(foldersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить файл',
            style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: foldersAsync.when(
        data: (folders) => _buildForm(context, t, folders),
        loading: () =>
            Center(child: CircularProgressIndicator(color: t.accent)),
        error: (e, _) => Center(
            child: Text('Ошибка: $e',
                style: AppTextStyles.bodyMedium.copyWith(color: t.danger))),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ArkvioTheme t, List<Folder> folders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File picker
          OutlinedButton.icon(
            onPressed: _pickedFilePath == null ? _pickFile : null,
            icon: Icon(Icons.attach_file, color: t.accent),
            label: Text(
              _pickedFileName ?? 'Выбрать файл',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button.copyWith(color: t.accent),
            ),
          ),
          if (_pickedFilePath != null) ...[
            const SizedBox(height: kSpaceXS),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pickedFileName ?? '',
                    style: AppTextStyles.caption.copyWith(color: t.accent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear, size: 18, color: t.inkMuted),
                  onPressed: () => setState(() {
                    _pickedFilePath = null;
                    _pickedFileName = null;
                  }),
                ),
              ],
            ),
          ],
          const SizedBox(height: kSpaceLG),

          // Title
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: kSpaceLG),

          // Folder selector
          DropdownButtonFormField<int?>(
            value: _selectedFolderId,
            style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
            decoration: const InputDecoration(labelText: 'Папка'),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Без папки',
                    style: AppTextStyles.bodyMedium.copyWith(color: t.inkMuted)),
              ),
              ...folders.map(
                (f) => DropdownMenuItem<int?>(
                  value: f.id,
                  child: Text(f.name,
                      style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _selectedFolderId = v),
          ),
          const SizedBox(height: kSpaceLG),

          // Tags
          TextField(
            controller: _tagsCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
            decoration: InputDecoration(
              labelText: 'Теги (через запятую)',
              hintText: 'например: ООО Альфа, аренда, март 2025',
              helperText: 'Теги помогут быстро найти документ через поиск',
              helperStyle: AppTextStyles.caption.copyWith(color: t.inkSubtle),
            ),
          ),
          const SizedBox(height: kSpaceLG),

          // Deadline toggle
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
                  lastDate:
                      DateTime.now().add(const Duration(days: 1825)),
                  locale: const Locale('ru'),
                );
                if (picked != null) {
                  setState(() => _deadlineDate = picked);
                }
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
              decoration: const InputDecoration(labelText: 'Напомнить за'),
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

          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: t.accent),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Сохранить',
                    style: AppTextStyles.buttonLarge
                        .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
