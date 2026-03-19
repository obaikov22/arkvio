import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class BackupService {
  /// Create a ZIP of all files in the app documents directory.
  /// Returns the path to the ZIP file.
  static Future<String> createBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, 'documents'));
    final encoder = ZipFileEncoder();

    final zipPath =
        p.join(appDir.path, 'arkvio_backup_${_timestamp()}.zip');
    encoder.create(zipPath);

    if (docsDir.existsSync()) {
      await for (final entity in docsDir.list(recursive: true)) {
        if (entity is File) {
          encoder.addFile(entity);
        }
      }
    }

    // Also backup the SQLite database file
    final dbFile = File(p.join(appDir.path, 'arkvio_db.sqlite'));
    if (dbFile.existsSync()) encoder.addFile(dbFile);

    encoder.close();
    return zipPath;
  }

  /// Share the backup ZIP via system share sheet
  static Future<void> shareBackup() async {
    final zipPath = await createBackup();
    await Share.shareXFiles(
      [XFile(zipPath)],
      subject: 'Arkvio — резервная копия',
    );
  }

  static String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }
}
