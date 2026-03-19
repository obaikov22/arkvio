# Arkvio — Phase 1 Prompt for Claude Code

## Context

Create a Flutter Android app called **Arkvio** — a local document storage app for a Russian-speaking accountant. The app stores files (PDF, DOCX, XLS, photos/scans) locally on the device, organized in folders, with deadlines and full-text search (OCR — Phase 2). All UI text must be in Russian. No internet, no Firebase, fully offline.

This is Phase 1: project foundation, database, navigation, folder management, file upload, and file list screens.

---

## Tech Stack

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.18.0           # SQLite ORM with FTS5 support
  drift_flutter: ^0.2.0    # Flutter integration for drift
  sqlite3_flutter_libs: ^0.5.0
  go_router: ^14.0.0       # Navigation
  flutter_riverpod: ^2.5.0 # State management
  riverpod_annotation: ^2.3.0
  file_picker: ^8.0.0      # Pick files from device
  path_provider: ^2.1.0    # App documents directory
  path: ^1.9.0
  intl: ^0.19.0            # Date formatting (Russian locale)
  uuid: ^4.4.0             # Generate unique IDs

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  drift_dev: ^2.18.0
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.0
  riverpod_lint: ^2.3.0
```

---

## Project Structure to Create

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + GoRouter setup
├── core/
│   ├── database/
│   │   ├── app_database.dart         # Drift database definition
│   │   ├── app_database.g.dart       # Generated (run build_runner)
│   │   ├── tables/
│   │   │   ├── folders_table.dart
│   │   │   ├── documents_table.dart
│   │   │   ├── tags_table.dart
│   │   │   └── fts_content_table.dart
│   │   └── daos/
│   │       ├── folders_dao.dart
│   │       └── documents_dao.dart
│   ├── services/
│   │   └── file_manager_service.dart # Copy files to app dir, delete
│   └── theme/
│       └── app_theme.dart            # Light + dark theme
├── features/
│   ├── home/
│   │   ├── home_screen.dart          # Main screen with urgent banner + folder grid
│   │   └── home_provider.dart
│   ├── folders/
│   │   ├── folder_list_screen.dart   # (same as home for now)
│   │   ├── folder_detail_screen.dart # Files inside a folder
│   │   └── folder_provider.dart
│   ├── documents/
│   │   ├── document_upload_screen.dart  # Add file form
│   │   ├── document_detail_screen.dart  # View file metadata
│   │   └── documents_provider.dart
│   ├── search/
│   │   └── search_screen.dart        # Placeholder for Phase 2
│   └── deadlines/
│       └── deadlines_screen.dart     # Placeholder for Phase 3
└── shared/
    ├── widgets/
    │   ├── file_type_badge.dart      # PDF/DOC/IMG badge chip
    │   ├── folder_card.dart          # Folder grid card
    │   ├── document_list_tile.dart   # File row in folder
    │   └── urgent_banner.dart        # Red urgent docs banner
    └── utils/
        ├── file_utils.dart           # Extension → type, size formatting
        └── date_utils.dart           # Deadline color logic
```

---

## Database Schema (Drift)

### `folders_table.dart`
```dart
import 'package:drift/drift.dart';

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get colorHex => text().withDefault(const Constant('#378ADD'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

### `documents_table.dart`
```dart
import 'package:drift/drift.dart';

class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().nullable().references(Folders, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get filePath => text()();           // Absolute path in app documents dir
  TextColumn get fileType => text()();           // 'pdf', 'docx', 'xlsx', 'image', 'other'
  IntColumn get fileSizeKb => integer().withDefault(const Constant(0))();
  DateTimeColumn get deadlineAt => dateTime().nullable()();
  IntColumn get reminderDays => integer().withDefault(const Constant(7))();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active | done | expired
  TextColumn get tags => text().withDefault(const Constant(''))(); // comma-separated tags
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

### `app_database.dart`
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/folders_table.dart';
import 'tables/documents_table.dart';
import 'daos/folders_dao.dart';
import 'daos/documents_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Folders, Documents], daos: [FoldersDao, DocumentsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'arkvio_db');
  }
}
```

---

## Navigation (GoRouter)

```dart
// app.dart — routes
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/folder/:id', builder: (_, state) => FolderDetailScreen(folderId: int.parse(state.pathParameters['id']!))),
    GoRoute(path: '/upload', builder: (_, state) => DocumentUploadScreen(folderId: state.uri.queryParameters['folderId'] != null ? int.parse(state.uri.queryParameters['folderId']!) : null)),
    GoRoute(path: '/document/:id', builder: (_, state) => DocumentDetailScreen(documentId: int.parse(state.pathParameters['id']!))),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/deadlines', builder: (_, __) => const DeadlinesScreen()),
  ],
);
```

---

## Key Screens to Implement

### 1. HomeScreen (`home_screen.dart`)

Layout (top to bottom):
- **AppBar**: title "Arkvio", action button — add folder (+ icon)
- **Urgent banner** (shown only if documents with deadlineAt within 14 days exist):
  - Orange/red container, title "Требуют внимания"
  - List of urgent document names (tap → navigate to document)
- **Section title**: "Папки"
- **Folder grid** (2 columns): FolderCard widgets for each folder
- **FAB**: "Добавить файл" — navigates to `/upload`
- **Bottom NavigationBar**: 4 items:
  - index 0: icon Icons.home_outlined / Icons.home, label "Главная"
  - index 1: icon Icons.search_outlined / Icons.search, label "Поиск" → /search
  - index 2: icon Icons.schedule_outlined / Icons.schedule, label "Сроки" → /deadlines
  - index 3: icon Icons.more_horiz, label "Ещё" (placeholder for now)

### 2. FolderDetailScreen (`folder_detail_screen.dart`)

- **AppBar**: folder name, back button, action: edit folder
- **Search bar** at top (local filter — filters displayed list, no OCR yet)
- **Document list**: DocumentListTile for each file
  - Left: colored file type badge (PDF red, DOC blue, XLS green, IMG teal)
  - Center: title, file size + type + upload date
  - Right: deadline badge if set ("До 31 мар" in red if urgent, "Актив" in green otherwise)
  - Tap → DocumentDetailScreen
- **FAB**: "Добавить файл" → `/upload?folderId=X`

### 3. DocumentUploadScreen (`document_upload_screen.dart`)

Steps in a single scrollable form:
1. **Pick file button** (file_picker, allowedExtensions: pdf, doc, docx, xls, xlsx, jpg, jpeg, png) — shows selected filename after picking
2. **Title field** (auto-filled from filename, editable)
3. **Folder selector** (DropdownButton with list of folders, nullable "Без папки")
4. **Tags field** (TextField, comma-separated, hint: "например: договор, ООО Альфа")
5. **Deadline toggle** (Switch "Установить срок")
   - If enabled: DatePicker button showing selected date
   - ReminderDays DropdownButton: "За 1 день / За 3 дня / За 7 дней"
6. **Save button** — copies file to app documents dir via FileManagerService, inserts into DB, pops back

### 4. DocumentDetailScreen (`document_detail_screen.dart`)

- **AppBar**: document title, delete action (with confirmation dialog)
- Show metadata cards:
  - Тип файла, Размер, Папка, Теги, Дедлайн (or "Не установлен"), Добавлен (date)
- **Open file button** → use `open_file` package to open in system app (add `open_file: ^3.3.2` to pubspec)
- **Edit deadline button** if no deadline set

---

## FileManagerService

```dart
// core/services/file_manager_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class FileManagerService {
  static const _uuid = Uuid();

  // Copy picked file into app documents directory, return new absolute path
  static Future<String> importFile(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, 'documents'));
    if (!docsDir.existsSync()) docsDir.createSync(recursive: true);

    final ext = p.extension(sourcePath);
    final newName = '${_uuid.v4()}$ext';
    final destPath = p.join(docsDir.path, newName);

    await File(sourcePath).copy(destPath);
    return destPath;
  }

  // Delete file from disk
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) await file.delete();
  }

  // Get file size in KB
  static int getFileSizeKb(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return 0;
    return (file.lengthSync() / 1024).round();
  }

  // Determine file type string from extension
  static String getFileType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    if (['.doc', '.docx'].contains(ext)) return 'docx';
    if (['.xls', '.xlsx'].contains(ext)) return 'xlsx';
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) return 'image';
    return 'other';
  }
}
```

---

## Theme (`app_theme.dart`)

Use Material 3. Primary color: `Color(0xFF378ADD)` (blue). Support both light and dark. Russian locale: add `'ru'` to `supportedLocales` and include `GlobalMaterialLocalizations.delegate`.

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF378ADD);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
    navigationBarTheme: const NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}
```

---

## Shared Widgets

### `folder_card.dart`
GridView card showing: folder color dot, folder name, file count. On tap → `/folder/:id`.

### `document_list_tile.dart`
ListTile with: colored type badge, title, metadata subtitle, deadline badge chip. Deadline chip color logic:
- No deadline → green "Актив"
- Deadline within 14 days → red "До {day} {month}"
- Deadline within 30 days → orange "До {day} {month}"
- Deadline further → grey date

### `urgent_banner.dart`
AnimatedContainer shown only when `urgentDocuments.isNotEmpty`. Orange border card listing up to 3 documents by name. "Показать все" link if more than 3.

### `file_type_badge.dart`
Small colored chip with label. Colors:
- pdf → red background, "PDF"
- docx → blue background, "DOC"
- xlsx → green background, "XLS"
- image → teal background, "IMG"
- other → grey, "FILE"

---

## Riverpod Providers

```dart
// Create these providers using @riverpod annotation:

// 1. Database provider (singleton)
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase();

// 2. All folders stream
@riverpod
Stream<List<Folder>> foldersStream(FoldersStreamRef ref) {
  return ref.watch(appDatabaseProvider).foldersDao.watchAllFolders();
}

// 3. Documents in folder
@riverpod
Stream<List<Document>> documentsInFolder(DocumentsInFolderRef ref, int folderId) {
  return ref.watch(appDatabaseProvider).documentsDao.watchDocumentsInFolder(folderId);
}

// 4. Urgent documents (deadline within 14 days)
@riverpod
Stream<List<Document>> urgentDocuments(UrgentDocumentsRef ref) {
  return ref.watch(appDatabaseProvider).documentsDao.watchUrgentDocuments(14);
}
```

---

## Russian Strings (hardcoded, no l10n package needed for Phase 1)

```dart
// All UI strings in Russian:
const kAppName = 'Arkvio';
const kTabHome = 'Главная';
const kTabSearch = 'Поиск';
const kTabDeadlines = 'Сроки';
const kTabMore = 'Ещё';
const kUrgentTitle = 'Требуют внимания';
const kFolders = 'Папки';
const kAddFile = 'Добавить файл';
const kAddFolder = 'Новая папка';
const kPickFile = 'Выбрать файл';
const kFileName = 'Название';
const kFolderLabel = 'Папка';
const kTagsLabel = 'Теги (через запятую)';
const kDeadlineLabel = 'Установить срок';
const kSave = 'Сохранить';
const kDelete = 'Удалить';
const kOpen = 'Открыть файл';
const kStatusActive = 'Актив';
const kNoFolder = 'Без папки';
const kConfirmDelete = 'Удалить документ?';
const kConfirmDeleteMsg = 'Файл будет удалён с устройства. Это действие необратимо.';
const kCancel = 'Отмена';
```

---

## `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ArkvioApp()));
}
```

---

## `app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
// import all screens

class ArkvioApp extends ConsumerWidget {
  const ArkvioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Arkvio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
```

---

## Instructions for Claude Code

1. Create the full project structure as described above
2. Implement ALL files listed — do not leave placeholder `// TODO` in critical logic
3. After creating all files, run: `dart run build_runner build --delete-conflicting-outputs`
4. The app must compile and run with `flutter run` without errors
5. Seed the database with **3 sample folders** on first launch (check if folders table is empty):
   - "Договоры" (blue #378ADD)
   - "Акты" (green #639922)
   - "Счета" (amber #BA7517)
6. Seed with **2 sample documents** in "Договоры" folder with hardcoded metadata (no actual file needed — use empty filePath `''` for seed data, skip file open for seed items)
7. HomeScreen must show the urgent banner if any document has `deadlineAt` within 14 days from today
8. Test on real device or emulator — confirm: folder creation works, file pick & import works, list updates reactively

---

## What Phase 1 Does NOT include (do not implement)

- OCR / text extraction (Phase 2)
- Full-text search (Phase 2)
- Push notifications / WorkManager (Phase 3)
- Backup/export (Phase 4)
- Onboarding screens (Phase 4)

---

## After Phase 1 is complete

Report back with:
- Screenshot or description of HomeScreen
- Any packages that had version conflicts (specify exact versions used)
- Any deviations from the plan and why
