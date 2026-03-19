part of '../app_database.dart';

@DriftAccessor(tables: [Folders])
class FoldersDao extends DatabaseAccessor<AppDatabase> with _$FoldersDaoMixin {
  FoldersDao(super.db);

  Stream<List<Folder>> watchAllFolders() =>
      (select(folders)
            ..orderBy([
              (t) => OrderingTerm.desc(t.pinned),
              (t) => OrderingTerm.asc(t.sortOrder),
            ]))
          .watch();

  Future<List<Folder>> getAllFolders() =>
      (select(folders)
            ..orderBy([
              (t) => OrderingTerm.desc(t.pinned),
              (t) => OrderingTerm.asc(t.sortOrder),
            ]))
          .get();

  Future<int> insertFolder(FoldersCompanion entry) =>
      into(folders).insert(entry);

  Future<bool> updateFolder(FoldersCompanion entry) =>
      update(folders).replace(entry);

  Future<int> deleteFolder(int id) =>
      (delete(folders)..where((t) => t.id.equals(id))).go();

  Future<Folder?> getFolderById(int id) =>
      (select(folders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> countFolders() async {
    final count = folders.id.count();
    final query = selectOnly(folders)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Batch-assigns sortOrder = index position in orderedIds.
  Future<void> reorderFolders(List<int> orderedIds) async {
    await batch((b) {
      for (int i = 0; i < orderedIds.length; i++) {
        b.update(
          folders,
          FoldersCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// Updates only the pinned flag (no full replace needed).
  Future<void> setFolderPinned(int id, bool pinned) =>
      (update(folders)..where((t) => t.id.equals(id)))
          .write(FoldersCompanion(pinned: Value(pinned)));
}
