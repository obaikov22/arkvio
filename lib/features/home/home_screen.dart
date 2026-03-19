import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';
import '../../core/services/file_manager_service.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/folder_card.dart';
import '../../shared/widgets/update_dialog.dart';
import '../../shared/widgets/urgent_banner.dart';
import '../folders/folder_provider.dart';
import '../documents/documents_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final update = await UpdateService.checkForUpdate();
    if (update != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateDialog(updateInfo: update),
      );
    }
  }

  static const _colors = [
    ('#2D6A4F', 'Зелёный'),
    ('#378ADD', 'Синий'),
    ('#BA7517', 'Янтарный'),
    ('#9B2335', 'Красный'),
    ('#8E24AA', 'Фиолетовый'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final foldersAsync = ref.watch(foldersStreamProvider);
    final urgentAsync = ref.watch(urgentDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Arkvio',
            style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder_outlined, color: t.inkMuted),
            tooltip: 'Новая папка',
            onPressed: () => _showAddFolderDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: RefreshIndicator(
        color: t.accent,
        onRefresh: () async => ref.invalidate(foldersStreamProvider),
        child: CustomScrollView(
          slivers: [
            // Urgent banner
            SliverToBoxAdapter(
              child: urgentAsync.when(
                data: (docs) => UrgentBanner(documents: docs),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            // "Папки" section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    kSpaceLG, kSpaceMD, kSpaceLG, kSpaceXS),
                child: Text(
                  'Папки',
                  style: AppTextStyles.titleMedium.copyWith(color: t.ink),
                ),
              ),
            ),
            // Folders reorderable list
            foldersAsync.when(
              data: (folders) {
                if (folders.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(kSpaceXXL),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open_outlined,
                                size: 48, color: t.inkSubtle),
                            const SizedBox(height: kSpaceLG),
                            Text(
                              'Нет папок',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: t.inkMuted),
                            ),
                            const SizedBox(height: kSpaceSM),
                            Text(
                              'Нажмите + чтобы создать первую папку',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: t.inkSubtle),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      kSpaceMD, kSpaceXS, kSpaceMD, kSpaceMD),
                  sliver: SliverReorderableList(
                    itemCount: folders.length,
                    onReorder: (oldIndex, newIndex) =>
                        _onReorder(folders, oldIndex, newIndex),
                    itemBuilder: (ctx, i) {
                      final folder = folders[i];
                      final t2 = ArkvioTheme.of(ctx);
                      return KeyedSubtree(
                        key: ValueKey(folder.id),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: kSpaceSM),
                          child: FolderCard(
                            folder: folder,
                            onLongPress: () =>
                                _showFolderMenu(context, folder, folders),
                            trailing: ReorderableDragStartListener(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.all(kSpaceMD),
                                child: Icon(Icons.drag_handle,
                                    color: t2.inkSubtle),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(kSpaceXXL),
                    child: CircularProgressIndicator(color: t.accent),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Text('Ошибка: $e',
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: t.danger)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context),
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Добавить',
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1) context.push('/search');
          if (i == 2) context.push('/deadlines');
          if (i == 3) context.push('/settings');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Поиск',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Сроки',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Ещё',
          ),
        ],
      ),
    );
  }

  // ── Drag-and-drop reorder ──────────────────────────────────────────────────

  void _onReorder(List<Folder> folders, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final pinnedCount = folders.where((f) => f.pinned).length;
    final moved = folders[oldIndex];
    final list = List<Folder>.from(folders)
      ..removeAt(oldIndex)
      ..insert(newIndex, moved);
    final db = ref.read(appDatabaseProvider);
    // Cross-zone drag → toggle pin status automatically
    if ((oldIndex < pinnedCount) != (newIndex < pinnedCount)) {
      await db.foldersDao.setFolderPinned(moved.id, newIndex < pinnedCount);
    }
    await db.foldersDao.reorderFolders(list.map((f) => f.id).toList());
  }

  // ── Long-press context menu ────────────────────────────────────────────────

  void _showFolderMenu(
      BuildContext context, Folder folder, List<Folder> folders) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  kSpaceLG, kSpaceXS, kSpaceLG, kSpaceSM),
              child: Text(
                folder.name,
                style: AppTextStyles.titleMedium.copyWith(color: t.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(height: 1, color: t.border),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: t.inkMuted),
              title: Text('Редактировать',
                  style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
              onTap: () {
                Navigator.pop(context);
                _showEditFolderDialog(context, folder);
              },
            ),
            ListTile(
              leading: Icon(
                folder.pinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: t.inkMuted,
              ),
              title: Text(
                folder.pinned ? 'Открепить' : 'Закрепить сверху',
                style: AppTextStyles.bodyMedium.copyWith(color: t.ink),
              ),
              onTap: () async {
                Navigator.pop(context);
                final db = ref.read(appDatabaseProvider);
                await db.foldersDao
                    .setFolderPinned(folder.id, !folder.pinned);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: t.danger),
              title: Text('Удалить',
                  style: AppTextStyles.bodyMedium.copyWith(color: t.danger)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteFolder(context, folder);
              },
            ),
            const SizedBox(height: kSpaceSM),
          ],
        ),
      ),
    );
  }

  // ── Edit folder ────────────────────────────────────────────────────────────

  void _showEditFolderDialog(BuildContext context, Folder folder) {
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
              style: FilledButton.styleFrom(
                backgroundColor: t.accent,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                    horizontal: kSpaceLG, vertical: kSpaceSM),
              ),
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

  // ── Delete folder ──────────────────────────────────────────────────────────

  void _confirmDeleteFolder(BuildContext context, Folder folder) {
    final t = ArkvioTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Удалить папку?',
            style: AppTextStyles.titleMedium.copyWith(color: t.ink)),
        content: Text(
          '«${folder.name}» и все документы в ней будут удалены с устройства. Это действие необратимо.',
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
              final db = ref.read(appDatabaseProvider);
              final docs =
                  await db.documentsDao.getDocumentsInFolder(folder.id);
              for (final doc in docs) {
                await FileManagerService.deleteFile(doc.filePath);
                await db.documentsDao.deleteDocument(doc.id);
              }
              await db.foldersDao.deleteFolder(folder.id);
            },
            child: Text('Удалить',
                style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Add menu (file or note) ────────────────────────────────────────────────

  void _showAddMenu(BuildContext context) {
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
                context.push('/upload');
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add_outlined, color: t.inkMuted),
              title: Text('Создать заметку',
                  style: AppTextStyles.bodyMedium.copyWith(color: t.ink)),
              onTap: () {
                Navigator.pop(context);
                context.push('/create-note');
              },
            ),
            const SizedBox(height: kSpaceSM),
          ],
        ),
      ),
    );
  }

  // ── Add folder ─────────────────────────────────────────────────────────────

  void _showAddFolderDialog(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final nameCtrl = TextEditingController();
    String selectedColor = '#2D6A4F';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: t.surface,
          title: Text('Новая папка',
              style: AppTextStyles.titleMedium.copyWith(color: t.ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
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
              style: FilledButton.styleFrom(
                backgroundColor: t.accent,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                    horizontal: kSpaceLG, vertical: kSpaceSM),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final db = ref.read(appDatabaseProvider);
                final all = await db.foldersDao.getAllFolders();
                final maxOrder = all.isEmpty
                    ? -1
                    : all.map((f) => f.sortOrder).reduce(max);
                await db.foldersDao.insertFolder(
                  FoldersCompanion(
                    name: Value(name),
                    colorHex: Value(selectedColor),
                    sortOrder: Value(maxOrder + 1),
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('Создать',
                  style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
