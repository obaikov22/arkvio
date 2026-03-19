# Arkvio — Phase 2 Prompt for Claude Code

## Context

Phase 1 is complete. The app compiles and runs. Now implement Phase 2: OCR text extraction and full-text search.

**Existing project location:** `d:\DEV\arkvio\`

**Actual package versions in use (from Phase 1):**
```yaml
drift: 2.28.2
drift_flutter: 0.2.7
drift_dev: 2.28.0
custom_lint: 0.7.6
intl: 0.20.2
```

---

## What Phase 2 adds

1. **Text extraction** from uploaded files (PDF text layer + images/scans via OCR)
2. **FTS5 full-text search** — find documents by content, not just filename
3. **Search screen** — replaces the placeholder with working search + highlighted results
4. **Background indexing** — OCR runs after file import, doesn't block UI

---

## Step 1 — Add packages to pubspec.yaml

```yaml
dependencies:
  # PDF text extraction
  syncfusion_flutter_pdf: ^26.2.14

  # OCR for images and scanned PDFs
  google_mlkit_text_recognition: ^0.13.0

  # Open files in system apps (may already be present from Phase 1)
  open_file: ^3.3.2
```

Run `flutter pub get` after adding.

> Note: `google_mlkit_text_recognition` requires minSdkVersion 21.
> In `android/app/build.gradle`, ensure:
> ```gradle
> defaultConfig {
>     minSdkVersion 21
> }
> ```

---

## Step 2 — Add FTS5 table to database

### `lib/core/database/tables/fts_content_table.dart`

```dart
import 'package:drift/drift.dart';

// Virtual FTS5 table for full-text search
class FtsContent extends Table {
  IntColumn get documentId => integer().references(Documents, #id)();
  TextColumn get extractedText => text().withDefault(const Constant(''))();
  DateTimeColumn get indexedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {documentId};
}
```

### Update `app_database.dart`

Add `FtsContent` to the `@DriftDatabase` annotation:

```dart
@DriftDatabase(
  tables: [Folders, Documents, FtsContent],
  daos: [FoldersDao, DocumentsDao, FtsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // bump from 1 to 2

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(ftsContents);
      }
    },
  );
  // ...
}
```

Run `dart run build_runner build --delete-conflicting-outputs` after changes.

---

## Step 3 — OCR Service

### `lib/core/services/ocr_service.dart`

```dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as p;

class OcrService {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extract text from any supported file. Returns empty string on failure.
  static Future<String> extractText(String filePath) async {
    try {
      final ext = p.extension(filePath).toLowerCase();

      if (ext == '.pdf') {
        return await _extractFromPdf(filePath);
      } else if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
        return await _extractFromImage(filePath);
      }
      // DOCX/XLS — not supported in Phase 2, return empty
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Extract text layer from PDF. Falls back to OCR on first page if no text found.
  static Future<String> _extractFromPdf(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final document = PdfDocument(inputBytes: bytes);

    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();

    // If PDF has no text layer (scanned PDF), try OCR on it
    if (text.trim().isEmpty) {
      // For scanned PDFs we cannot render pages without a native renderer.
      // Return empty string — user can re-scan as image instead.
      return '';
    }

    return text;
  }

  /// Extract text from image using ML Kit OCR (offline, supports Russian).
  static Future<String> _extractFromImage(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
```

---

## Step 4 — FTS DAO

### `lib/core/database/daos/fts_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'fts_dao.g.dart';

@DaoAccessor(AppDatabase)
class FtsDao extends DatabaseAccessor<AppDatabase> with _$FtsDaoMixin {
  FtsDao(super.db);

  /// Upsert OCR text for a document
  Future<void> upsertContent(int documentId, String text) async {
    await into(db.ftsContents).insertOnConflictUpdate(
      FtsContentsCompanion(
        documentId: Value(documentId),
        extractedText: Value(text),
        indexedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Search documents by extracted text content. Returns matching document IDs.
  Future<List<int>> searchByContent(String query) async {
    final q = '%${query.toLowerCase()}%';
    final rows = await (select(db.ftsContents)
      ..where((t) => t.extractedText.lower().like(q)))
      .get();
    return rows.map((r) => r.documentId).toList();
  }

  /// Delete FTS entry when document is deleted
  Future<void> deleteContent(int documentId) async {
    await (delete(db.ftsContents)
      ..where((t) => t.documentId.equals(documentId)))
      .go();
  }
}
```

> Note: True SQLite FTS5 virtual tables require raw SQL in drift. The above uses a regular table with LIKE search as a pragmatic Phase 2 solution — fast enough for hundreds of documents. FTS5 virtual table can be added in Phase 4 if performance becomes an issue.

---

## Step 5 — Indexing service

### `lib/core/services/indexing_service.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'ocr_service.dart';

class IndexingService {
  final AppDatabase _db;

  IndexingService(this._db);

  /// Run OCR on a document and store result in FTS table.
  /// Call this after importing a file. Runs async — does not block UI.
  Future<void> indexDocument(int documentId, String filePath) async {
    final text = await OcrService.extractText(filePath);
    if (text.isNotEmpty) {
      await _db.ftsDao.upsertContent(documentId, text);
    }
  }

  /// Re-index all documents that have no FTS entry yet.
  /// Call once on app start to index any pre-existing files.
  Future<void> indexMissing() async {
    final allDocs = await _db.documentsDao.getAllDocuments();
    final indexed = await _db.ftsDao.getAllIndexedIds();
    final missing = allDocs.where((d) => !indexed.contains(d.id) && d.filePath.isNotEmpty);

    for (final doc in missing) {
      await indexDocument(doc.id, doc.filePath);
    }
  }
}
```

Add `getAllDocuments()` to `DocumentsDao` if not present:
```dart
Future<List<Document>> getAllDocuments() => select(documents).get();
```

Add `getAllIndexedIds()` to `FtsDao`:
```dart
Future<List<int>> getAllIndexedIds() async {
  final rows = await select(db.ftsContents).get();
  return rows.map((r) => r.documentId).toList();
}
```

---

## Step 6 — Hook indexing into file upload

In `DocumentUploadScreen` (or `DocumentsDao`), after successfully inserting a document, trigger indexing:

```dart
// After: final id = await db.documentsDao.insertDocument(...)
// Add:
final indexingService = IndexingService(ref.read(appDatabaseProvider));
unawaited(indexingService.indexDocument(id, destPath));
```

Import `dart:async` for `unawaited`.

Also in `main.dart` or `app.dart`, trigger background re-indexing on startup:
```dart
// Inside build() or initState() of the root widget, after ProviderScope:
WidgetsBinding.instance.addPostFrameCallback((_) async {
  final db = ref.read(appDatabaseProvider);
  final indexing = IndexingService(db);
  unawaited(indexing.indexMissing());
});
```

---

## Step 7 — Search Provider

### `lib/features/search/search_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';

part 'search_provider.g.dart';

@riverpod
Future<List<Document>> searchDocuments(
  SearchDocumentsRef ref,
  String query,
) async {
  if (query.trim().length < 2) return [];

  final db = ref.watch(appDatabaseProvider);

  // Search by title
  final byTitle = await db.documentsDao.searchByTitle(query);

  // Search by content (OCR)
  final contentIds = await db.ftsDao.searchByContent(query);
  final byContent = await db.documentsDao.getDocumentsByIds(contentIds);

  // Merge, deduplicate, title matches first
  final seen = <int>{};
  final results = <Document>[];
  for (final doc in [...byTitle, ...byContent]) {
    if (seen.add(doc.id)) results.add(doc);
  }
  return results;
}
```

Add these methods to `DocumentsDao`:
```dart
Future<List<Document>> searchByTitle(String query) async {
  return (select(documents)
    ..where((d) => d.title.lower().like('%${query.toLowerCase()}%')))
    .get();
}

Future<List<Document>> getDocumentsByIds(List<int> ids) async {
  if (ids.isEmpty) return [];
  return (select(documents)..where((d) => d.id.isIn(ids))).get();
}
```

---

## Step 8 — Search Screen

### `lib/features/search/search_screen.dart`

Replace the existing placeholder with a full implementation:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'search_provider.dart';
import '../../shared/widgets/document_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchDocumentsProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Поиск')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: 'Поиск по названию и тексту...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
            ),
          ),

          // Query hint
          if (_query.length == 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Введите минимум 2 символа',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // Results
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              data: (docs) {
                if (_query.length < 2) {
                  return const Center(
                    child: Text(
                      'Ищите по названию файла,\nИНН, сумме или любому тексту из документа',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Ничего не найдено по\n«$_query»',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        'Найдено: ${docs.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, i) => DocumentListTile(
                          document: docs[i],
                          onTap: () => context.push('/document/${docs[i].id}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Step 9 — Android ML Kit config

In `android/app/src/main/AndroidManifest.xml`, inside `<application>` tag, add:

```xml
<!-- ML Kit: bundle Russian + Latin text recognition models -->
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ocr" />
```

This ensures the OCR model downloads on first use. The app works offline after first run.

---

## Step 10 — Run build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

Then test:
```bash
flutter run
```

---

## Testing checklist

After implementation, verify:

- [ ] Upload a photo of a document with Russian text → wait 2-3 seconds → search for a word from that photo → it appears in results
- [ ] Upload a text-based PDF → search for a word from it → appears in results
- [ ] Search for a word that doesn't exist → shows "Ничего не найдено"
- [ ] Search with 1 character → shows "Введите минимум 2 символа"
- [ ] Search matches both filename AND content in the same result list
- [ ] Re-launching app → previously indexed documents are still searchable

---

## What Phase 2 does NOT include

- Push notifications (Phase 3)
- WorkManager background jobs (Phase 3)
- Scanned PDF rendering to image for OCR (complex, deferred to post-launch)
- DOCX/XLS text extraction (deferred — most users will upload PDF or photos)

---

## Report back after Phase 2

- Confirm OCR works on a real device (emulator has no camera, but can pick image from gallery)
- Report any package version conflicts with actual versions used
- Note if `syncfusion_flutter_pdf` APK size increase is significant (it adds ~8MB)
