import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/folders_table.dart';
import 'tables/documents_table.dart';
import 'tables/notes_table.dart';

part 'app_database.g.dart';
part 'daos/folders_dao.dart';
part 'daos/documents_dao.dart';
part 'daos/notes_dao.dart';

@DriftDatabase(tables: [Folders, Documents, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 3) {
        await customStatement('DROP TABLE IF EXISTS fts_contents');
      }
      if (from < 4) {
        await migrator.addColumn(folders, folders.pinned);
      }
      if (from < 5) {
        await migrator.addColumn(documents, documents.content);
      }
      if (from < 6) {
        await migrator.createTable(notes);
      }
    },
  );

  late final foldersDao = FoldersDao(this);
  late final documentsDao = DocumentsDao(this);
  late final notesDao = NotesDao(this);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'arkvio_db');
  }
}
