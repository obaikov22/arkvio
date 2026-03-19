import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';
import '../folders/folder_provider.dart';

part 'deadlines_provider.g.dart';

@riverpod
Stream<List<Document>> documentsWithDeadlines(DocumentsWithDeadlinesRef ref) {
  return ref
      .watch(appDatabaseProvider)
      .documentsDao
      .watchDocumentsWithDeadlines();
}
