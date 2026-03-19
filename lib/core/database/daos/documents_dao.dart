part of '../app_database.dart';

@DriftAccessor(tables: [Documents, Folders])
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.db);

  Stream<List<Document>> watchDocumentsInFolder(int folderId) =>
      (select(documents)
            ..where((t) => t.folderId.equals(folderId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<Document>> watchUrgentDocuments(int withinDays) {
    final deadline = DateTime.now().add(Duration(days: withinDays));
    return (select(documents)
          ..where(
            (t) =>
                t.deadlineAt.isNotNull() &
                t.deadlineAt.isSmallerOrEqualValue(deadline) &
                t.status.equals('active'),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.deadlineAt)]))
        .watch();
  }

  Stream<List<Document>> watchAllDocuments() =>
      (select(documents)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<Document>> getDocumentsInFolder(int folderId) =>
      (select(documents)
            ..where((t) => t.folderId.equals(folderId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<Document?> getDocumentById(int id) =>
      (select(documents)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Document?> watchDocumentById(int id) =>
      (select(documents)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> insertDocument(DocumentsCompanion entry) =>
      into(documents).insert(entry);

  Future<bool> updateDocument(DocumentsCompanion entry) =>
      update(documents).replace(entry);

  Future<int> deleteDocument(int id) =>
      (delete(documents)..where((t) => t.id.equals(id))).go();

  Future<int> countDocumentsInFolder(int folderId) async {
    final count = documents.id.count();
    final query = selectOnly(documents)
      ..addColumns([count])
      ..where(documents.folderId.equals(folderId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<int> watchDocumentCountInFolder(int folderId) {
    final count = documents.id.count();
    return (selectOnly(documents)
          ..addColumns([count])
          ..where(documents.folderId.equals(folderId)))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Future<List<Document>> getAllDocuments() => select(documents).get();

  /// Search by title, tags, and file type. Cyrillic-safe — done in Dart.
  Future<List<Document>> searchDocuments(String query) async {
    final allDocs = await select(documents).get();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return allDocs.where((doc) {
      final titleMatch = doc.title.toLowerCase().contains(q);
      final tagsMatch = doc.tags.toLowerCase().contains(q);
      final typeMatch = doc.fileType.toLowerCase().contains(q);
      return titleMatch || tagsMatch || typeMatch;
    }).toList();
  }

  Future<List<Document>> getDocumentsWithDeadlines() {
    return (select(documents)
          ..where((d) => d.deadlineAt.isNotNull())
          ..orderBy([(d) => OrderingTerm.asc(d.deadlineAt)]))
        .get();
  }

  Stream<List<Document>> watchDocumentsWithDeadlines() {
    return (select(documents)
          ..where((d) => d.deadlineAt.isNotNull())
          ..where((d) => d.status.isNotValue('done'))
          ..orderBy([(d) => OrderingTerm.asc(d.deadlineAt)]))
        .watch();
  }

  Future<List<Document>> getDocumentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(documents)
          ..where((d) =>
              d.createdAt.isBiggerOrEqualValue(start) &
              d.createdAt.isSmallerThanValue(end))
          ..orderBy([(d) => OrderingTerm.asc(d.createdAt)]))
        .get();
  }

  Future<Set<DateTime>> getDatesWithDocuments(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await (select(documents)
          ..where((d) =>
              d.createdAt.isBiggerOrEqualValue(start) &
              d.createdAt.isSmallerThanValue(end)))
        .get();
    return rows
        .map((d) =>
            DateTime(d.createdAt.year, d.createdAt.month, d.createdAt.day))
        .toSet();
  }
}
