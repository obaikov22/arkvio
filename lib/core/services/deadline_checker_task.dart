import 'package:workmanager/workmanager.dart';
import '../database/app_database.dart';
import 'notification_service.dart';

const kDeadlineCheckTask = 'arkvio.deadline_check';

/// Called by WorkManager in background isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != kDeadlineCheckTask) return true;

    try {
      final db = AppDatabase();
      final now = DateTime.now();

      final docs = await db.documentsDao.getDocumentsWithDeadlines();

      for (final doc in docs) {
        if (doc.deadlineAt == null) continue;
        if (doc.status == 'done') continue;

        final daysLeft = doc.deadlineAt!.difference(now).inDays;
        final reminderDays = doc.reminderDays ?? 7;

        // Notify if within reminder window and not expired
        if (daysLeft >= 0 && daysLeft <= reminderDays) {
          await NotificationService.showDeadlineNotification(
            documentId: doc.id,
            documentTitle: doc.title,
            daysLeft: daysLeft,
          );
        }
      }

      await db.close();
    } catch (_) {
      // Silent fail — WorkManager will retry
    }

    return true;
  });
}
