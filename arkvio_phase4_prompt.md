# Arkvio — Phase 4 Prompt for Claude Code

## Context

Phases 1–3 are complete. The app compiles, runs, OCR search works, deadlines screen works, push notifications via WorkManager are set up.

**Project location:** `d:\DEV\arkvio\`

Phase 4 is the final phase: UX polish, onboarding, backup/restore, swipe gestures, and dark theme fixes.

---

## What Phase 4 adds

1. **Onboarding** — 3 screens shown only on first launch
2. **Swipe gestures** — swipe left to delete, swipe right to share on document tiles
3. **Sorting & filtering** — sort documents by date/name/size, filter by file type
4. **Backup & restore** — export everything to ZIP, import from ZIP
5. **Dark theme** — verify all screens look correct in dark mode, fix any hardcoded colors
6. **Empty states** — friendly illustrations/messages on empty folders and screens
7. **Release APK** — signed build ready to install

---

## Step 1 — Add packages

```yaml
dependencies:
  archive: ^3.6.1          # ZIP creation and extraction
  share_plus: ^10.0.0      # Share file via system sheet
  shared_preferences: ^2.3.0  # Store "onboarding done" flag
  permission_handler: ^11.3.0 # Storage permission for backup
```

Run `flutter pub get`.

---

## Step 2 — Onboarding

### `lib/features/onboarding/onboarding_screen.dart`

Show only on first launch (check via `SharedPreferences`). Three pages, PageView with dots indicator, skip button, and "Начать" button on last page.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      subtitle: 'Храните договоры, акты, счета и сканы прямо на телефоне. Без облака — всё локально.',
    ),
    _OnboardingPage(
      icon: Icons.search_outlined,
      title: 'Найдите любой документ за секунду',
      subtitle: 'Поиск работает по тексту внутри файлов. Введите ИНН, название компании или сумму.',
    ),
    _OnboardingPage(
      icon: Icons.schedule_outlined,
      title: 'Не пропустите важный срок',
      subtitle: 'Установите дедлайн для документа — Arkvio напомнит за несколько дней.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Пропустить'),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i
                      ? colorScheme.primary
                      : colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

            const SizedBox(height: 32),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(isLast ? 'Начать' : 'Далее'),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### Hook onboarding into app startup

In `main.dart`, before `runApp`, check the flag:

```dart
final prefs = await SharedPreferences.getInstance();
final onboardingDone = prefs.getBool('onboarding_done') ?? false;
```

In `app.dart`, pass `onboardingDone` to GoRouter's `initialLocation`:

```dart
GoRouter buildRouter(bool onboardingDone) => GoRouter(
  navigatorKey: ArkvioRouter.navigatorKey,
  initialLocation: onboardingDone ? '/' : '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    // ... existing routes
  ],
);
```

---

## Step 3 — Swipe gestures on document tiles

Wrap `DocumentListTile` with `Dismissible` in `FolderDetailScreen` and `DeadlinesScreen`:

```dart
Dismissible(
  key: ValueKey(doc.id),
  // Swipe LEFT → delete
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red.shade400,
    child: const Icon(Icons.delete_outline, color: Colors.white),
  ),
  direction: DismissDirection.endToStart,
  confirmDismiss: (_) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить документ?'),
        content: Text('«${doc.title}» будет удалён с устройства. Это действие необратимо.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  },
  onDismissed: (_) async {
    await ref.read(appDatabaseProvider).documentsDao.deleteDocument(doc.id);
    await FileManagerService.deleteFile(doc.filePath);
    await ref.read(appDatabaseProvider).ftsDao.deleteContent(doc.id);
  },
  child: DocumentListTile(document: doc, onTap: () => context.push('/document/${doc.id}')),
)
```

Add `deleteDocument(int id)` to `DocumentsDao` if not present:
```dart
Future<void> deleteDocument(int id) async {
  await (delete(documents)..where((d) => d.id.equals(id))).go();
}
```

---

## Step 4 — Sorting & filtering in FolderDetailScreen

Add a sort bar below the search field:

```dart
// Sort options
enum SortOption { dateDesc, dateAsc, nameAsc, sizeDesc }

// Filter options (multi-select)
// 'pdf', 'docx', 'xlsx', 'image', 'other', or null = all
```

UI: a horizontal `SingleChildScrollView` of `FilterChip` widgets for file types, and a `PopupMenuButton` icon in the AppBar for sort order.

Apply sorting/filtering client-side in the provider or directly in the widget's local state — no need for DB changes.

---

## Step 5 — Backup & Restore

### `lib/core/services/backup_service.dart`

```dart
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class BackupService {
  /// Create a ZIP of all files in the app documents directory.
  /// Returns the path to the ZIP file.
  static Future<String> createBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, 'documents'));
    final encoder = ZipFileEncoder();

    final zipPath = p.join(appDir.path, 'arkvio_backup_${_timestamp()}.zip');
    encoder.create(zipPath);

    if (docsDir.existsSync()) {
      await for (final entity in docsDir.list(recursive: true)) {
        if (entity is File) {
          encoder.addFile(entity);
        }
      }
    }

    // Also backup the SQLite database file
    final dbFile = File(p.join(appDir.path, 'arkvio_db.sqlite'));
    if (dbFile.existsSync()) encoder.addFile(dbFile);

    encoder.close();
    return zipPath;
  }

  /// Share the backup ZIP via system share sheet
  static Future<void> shareBackup() async {
    final zipPath = await createBackup();
    await Share.shareXFiles(
      [XFile(zipPath)],
      subject: 'Arkvio — резервная копия',
    );
  }

  static String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}';
  }
}
```

---

## Step 6 — Settings screen ("Ещё" tab)

Replace the "Ещё" placeholder tab with a simple settings screen:

### `lib/features/settings/settings_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/backup_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ещё')),
      body: ListView(
        children: [
          const _SectionHeader('Данные'),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Создать резервную копию'),
            subtitle: const Text('Сохранить все файлы и базу данных'),
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
          const Divider(height: 1),
          const _SectionHeader('О приложении'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Arkvio'),
            subtitle: const Text('Версия 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Хранилище'),
            subtitle: const Text('Все данные хранятся локально на устройстве'),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
```

Add route `/settings` and wire up the "Ещё" tab to navigate there.

---

## Step 7 — Empty states

In `FolderDetailScreen`, when the document list is empty:

```dart
// Empty state widget
Center(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.folder_open_outlined, size: 56, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text(
          'Папка пуста',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'Нажмите + чтобы добавить первый документ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
)
```

Apply similar empty states to `HomeScreen` (no folders yet) and `SearchScreen` (before typing).

---

## Step 8 — Dark theme audit

Go through every screen and fix any hardcoded colors that break in dark mode. Common issues:

- `Colors.grey.shade200` as background → replace with `Theme.of(context).colorScheme.surfaceVariant`
- `Colors.white` as card background → replace with `Theme.of(context).colorScheme.surface`
- `Color(0xFF...)` hardcoded → replace with colorScheme equivalents
- Any `Colors.black` text → replace with `colorScheme.onSurface`

Test by wrapping the root in `Theme(data: ThemeData.dark(), ...)` temporarily, or switching device to dark mode.

---

---

## Testing checklist

- [ ] First launch shows onboarding → "Начать" → goes to HomeScreen
- [ ] Second launch skips onboarding → goes directly to HomeScreen
- [ ] Swipe left on a document in folder → delete confirmation → document removed
- [ ] Settings tab → "Создать резервную копию" → share sheet appears with ZIP file
- [ ] Dark mode: all screens look correct, no white boxes on dark background
- [ ] Empty folder shows friendly empty state message

---

## Report back after Phase 4

Confirm all checklist items pass on a real device. After testing is done, release APK signing will be done separately.
