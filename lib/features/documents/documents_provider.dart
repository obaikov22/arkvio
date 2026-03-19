import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';
import '../folders/folder_provider.dart';

part 'documents_provider.g.dart';

@riverpod
Stream<List<Document>> documentsInFolder(
  DocumentsInFolderRef ref,
  int folderId,
) {
  return ref
      .watch(appDatabaseProvider)
      .documentsDao
      .watchDocumentsInFolder(folderId);
}

@riverpod
Stream<List<Document>> urgentDocuments(UrgentDocumentsRef ref) {
  return ref
      .watch(appDatabaseProvider)
      .documentsDao
      .watchUrgentDocuments(14);
}

@riverpod
Stream<Document?> documentById(DocumentByIdRef ref, int id) {
  return ref.watch(appDatabaseProvider).documentsDao.watchDocumentById(id);
}

@riverpod
Stream<int> documentCountInFolder(DocumentCountInFolderRef ref, int folderId) {
  return ref
      .watch(appDatabaseProvider)
      .documentsDao
      .watchDocumentCountInFolder(folderId);
}
