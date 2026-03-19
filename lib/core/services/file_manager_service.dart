import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class FileManagerService {
  static const _uuid = Uuid();

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

  static Future<void> deleteFile(String filePath) async {
    if (filePath.isEmpty) return;
    final file = File(filePath);
    if (file.existsSync()) await file.delete();
  }

  static int getFileSizeKb(String filePath) {
    if (filePath.isEmpty) return 0;
    final file = File(filePath);
    if (!file.existsSync()) return 0;
    return (file.lengthSync() / 1024).round();
  }

  static String getFileType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    if (['.doc', '.docx'].contains(ext)) return 'docx';
    if (['.xls', '.xlsx'].contains(ext)) return 'xlsx';
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) return 'image';
    return 'other';
  }
}
