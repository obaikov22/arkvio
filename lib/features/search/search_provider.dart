import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';
import '../folders/folder_provider.dart';

part 'search_provider.g.dart';

@riverpod
Future<List<Document>> searchDocuments(
  SearchDocumentsRef ref,
  String query,
) async {
  if (query.trim().length < 2) return [];
  final db = ref.watch(appDatabaseProvider);
  return db.documentsDao.searchDocuments(query);
}
