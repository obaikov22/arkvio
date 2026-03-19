import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/services/file_manager_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/document_list_tile.dart';
import '../documents/documents_provider.dart';
import 'folder_provider.dart';

enum _SortOption { dateDesc, dateAsc, nameAsc, sizeDesc }

class FolderDetailScreen extends ConsumerStatefulWidget {
  final int folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  ConsumerState<FolderDetailScreen> createState() =>
      _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  _SortOption _sortOption = _SortOption.dateDesc;
  final Set<String> _filterTypes = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Document> _applyFilters(List<Document> docs) {
    var result = docs.toList();

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((d) => d.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (_filterTypes.isNotEmpty) {
      result =
          result.where((d) => _filterTypes.contains(d.fileType)).toList();
    }

    switch (_sortOption) {
      case _SortOption.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.nameAsc:
        result.sort((a, b) => a.title.compareTo(b.title));
      case _SortOption.sizeDesc:
        result.sort((a, b) => b.fileSizeKb.compareTo(a.fileSizeKb));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final folderAsync = ref.watch(folderByIdProvider(widget.folderId));
    final docsAsync = ref.watch(documentsInFolderProvider(widget.folderId));

    return Scaffold(
      appBar: AppBar(
        title: folderAsync.when(
          data: (f) => Text(f?.name ?? 'Папка',
              style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
          loading: () => Text('Загрузка...',
              style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
          error: (_, __) => Text('Папка',
              style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        ),
        actions: [
          folderAsync.when(
            data: (folder) => folder != null
                ? IconButton(
                    icon: Icon(Icons.edit_outlined, color: t.inkMuted),
                    onPressed: () => _showEditDialog(context, folder),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          PopupMenuButton<_SortOption>(
            icon: Icon(Icons.sort, color: t.inkMuted),
            tooltip: 'Сортировка',
            onSelected: (opt) => setState(() => _sortOption = opt),
            itemBuilder: (_) => [
              _sortItem(context, 'Сначала новые', _SortOption.dateDesc),
              _sortItem(context, 'Сначала старые', _SortOption.dateAsc),
              _sortItem(context, 'По названию', _SortOption.nameAsc),
              _sortItem(context, 'По размеру', _SortOption.sizeDesc),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                kSpaceMD, kSpaceMD, kSpaceMD, kSpaceXS),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
              decoration: InputDecoration(
                hintText: 'Поиск по названию...',
                hintStyle:
                    AppTextStyles.bodyMedium.copyWith(color: t.inkSubtle),
                prefixIcon: Icon(Icons.search, color: t.inkSubtle),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: t.inkMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: kSpaceMD, vertical: kSpaceXS),
            child: Row(
              children: ['pdf', 'docx', 'xlsx', 'image', 'other']
                  .map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: kSpaceSM),
                      child: FilterChip(
                        label: Text(
                          type.toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                            color: _filterTypes.contains(type)
                                ? t.accent
                                : t.inkMuted,
                          ),
                        ),
                        selected: _filterTypes.contains(type),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _filterTypes.add(type);
                          } else {
                            _filterTypes.remove(type);
                          }
                        }),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: docsAsync.when(
              data: (docs) {
                final filtered = _applyFilters(docs);

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(kSpaceXXL),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_outlined,
                              size: 56, color: t.inkSubtle),
                          const SizedBox(height: kSpaceLG),
                          Text(
                            _searchQuery.isEmpty && _filterTypes.isEmpty
                                ? 'Папка пуста'
                                : 'Ничего не найдено',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: t.inkMuted),
                          ),
                          const SizedBox(height: kSpaceSM),
                          if (_searchQuery.isEmpty && _filterTypes.isEmpty)
                            Text(
                              'Нажмите + чтобы добавить первый документ',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: t.inkSubtle),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kSpaceMD, vertical: kSpaceSM),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: kSpaceSM),
                  itemBuilder: (_, i) {
                    final doc = filtered[i];
                    return Dismissible(
                      key: ValueKey(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: kSpaceXL),
                        decoration: BoxDecoration(
                          color: t.danger,
                          borderRadius: BorderRadius.circular(kRadiusLG),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: t.surface,
                            title: Text('Удалить документ?',
                                style: AppTextStyles.titleMedium
                                    .copyWith(color: t.ink)),
                            content: Text(
                              '«${doc.title}» будет удалён с устройства. Это действие необратимо.',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: t.inkMuted),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text('Отмена',
                                    style: AppTextStyles.button
                                        .copyWith(color: t.inkMuted)),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                    backgroundColor: t.danger),
                                child: Text('Удалить',
                                    style: AppTextStyles.button
                                        .copyWith(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        final db = ref.read(appDatabaseProvider);
                        await db.documentsDao.deleteDocument(doc.id);
                        await FileManagerService.deleteFile(doc.filePath);
                      },
                      child: DocumentListTile(document: doc),
                    );
                  },
                );
              },
              loading: () =>
                  Center(child: CircularProgressIndicator(color: t.accent)),
              error: (e, _) => Center(
                  child: Text('Ошибка: $e',
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: t.danger))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context, widget.folderId),
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add, size: 20),
        label: Text('Добавить',
            style: AppTextStyles.button.copyWith(color: Colors.white)),
      ),
    );
  }

  PopupMenuItem<_SortOption> _sortItem(
      BuildContext context, String label, _SortOption value) {
    final t = ArkvioTheme.of(context);
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        SizedBox(
            width: 20,
            child: _sortOption == value
                ? Icon(Icons.check, size: 16, color: t.accent)
                : null),
        const SizedBox(width: kSpaceSM),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
      ]),
    );
  }

  void _showAddMenu(BuildContext context, int folderId) {
    final t = ArkvioTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: kSpaceSM, bottom: kSpaceXS),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: t.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.upload_file_outlined, color: t.inkMuted),
              title: Text('Загрузить файл',
                  style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
              onTap: () {
                Navigator.pop(context);
                context.push('/upload?folderId=$folderId');
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add_outlined, color: t.inkMuted),
              title: Text('Создать заметку',
                  style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
              onTap: () {
                Navigator.pop(context);
                context.push('/create-note?folderId=$folderId');
              },
            ),
            const SizedBox(height: kSpaceSM),
          ],
        ),
      ),
    );
  }

  static const _colors = [
    ('#2D6A4F', 'Зелёный'),
    ('#378ADD', 'Синий'),
    ('#BA7517', 'Янтарный'),
    ('#9B2335', 'Красный'),
    ('#8E24AA', 'Фиолетовый'),
  ];

  void _showEditDialog(BuildContext context, Folder folder) {
    final t = ArkvioTheme.of(context);
    final nameCtrl = TextEditingController(text: folder.name);
    String selectedColor = folder.colorHex;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: t.surface,
          title: Text('Редактировать папку',
              style: AppTextStyles.titleMedium.copyWith(color: t.ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
                decoration: const InputDecoration(labelText: 'Название'),
                autofocus: true,
              ),
              const SizedBox(height: kSpaceMD),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Цвет:',
                    style: AppTextStyles.caption.copyWith(color: t.inkMuted)),
              ),
              const SizedBox(height: kSpaceSM),
              Wrap(
                spacing: kSpaceSM,
                children: _colors.map((c) {
                  final hex = c.$1.replaceFirst('#', '');
                  final colorVal = int.tryParse(hex, radix: 16) ?? 0;
                  final color = Color(0xFF000000 | colorVal);
                  final isSelected = selectedColor == c.$1;
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedColor = c.$1),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: color,
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отмена',
                  style: AppTextStyles.button.copyWith(color: t.inkMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: t.accent),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final db = ref.read(appDatabaseProvider);
                await db.foldersDao.updateFolder(
                  FoldersCompanion(
                    id: Value(folder.id),
                    name: Value(name),
                    colorHex: Value(selectedColor),
                    sortOrder: Value(folder.sortOrder),
                    pinned: Value(folder.pinned),
                    createdAt: Value(folder.createdAt),
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('Сохранить',
                  style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
