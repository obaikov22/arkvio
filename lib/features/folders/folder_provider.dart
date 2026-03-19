import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';

part 'folder_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase();

@riverpod
Stream<List<Folder>> foldersStream(FoldersStreamRef ref) {
  return ref.watch(appDatabaseProvider).foldersDao.watchAllFolders();
}

@riverpod
Future<Folder?> folderById(FolderByIdRef ref, int id) {
  return ref.watch(appDatabaseProvider).foldersDao.getFolderById(id);
}
