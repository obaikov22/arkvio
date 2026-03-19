# Arkvio — Phase 3 Prompt for Claude Code

## Context

Phases 1 and 2 are complete. The app compiles, runs, and OCR search works.
Now implement Phase 3: deadlines screen + daily push notifications via WorkManager.

**Project location:** `d:\DEV\arkvio\`

**Actual package versions in use:**
```yaml
drift: 2.28.2
drift_flutter: 0.2.7
drift_dev: 2.28.0
custom_lint: 0.7.6
intl: 0.20.2
syncfusion_flutter_pdf: 33.1.44
google_mlkit_text_recognition: 0.13.0
```

---

## What Phase 3 adds

1. **Deadlines screen** — replaces placeholder, shows all documents with deadlines sorted by urgency, color-coded
2. **Local push notifications** — remind user about upcoming deadlines each morning
3. **WorkManager** — daily background task at 09:00 that checks deadlines and fires notifications
4. **Notification on document open** — tap notification → open that document directly

---

## Step 1 — Add packages

```yaml
dependencies:
  flutter_local_notifications: ^18.0.0
  workmanager: ^0.5.2
  flutter_timezone: ^2.0.0
  timezone: ^0.9.4
```

Run `flutter pub get`.

---

## Step 2 — Android permissions

In `android/app/src/main/AndroidManifest.xml`, add inside `<manifest>` (before `<application>`):

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"
    tools:ignore="ProtectedPermissions"/>
```

Inside `<application>`:

```xml
<!-- WorkManager BroadcastReceiver for rescheduling on reboot -->
<receiver
    android:name="androidx.work.impl.utils.ForceStopRunnable$BroadcastReceiver"
    android:enabled="true"
    android:exported="true"
    android:directBootAware="true" />
```

Add `xmlns:tools="http://schemas.android.com/tools"` to the `<manifest>` tag if not present.

---

## Step 3 — Notification Service

### `lib/core/services/notification_service.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'arkvio_deadlines',
      'Сроки документов',
      description: 'Напоминания о дедлайнах документов',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // payload = document id as string
    // Navigation is handled via a global navigator key — see Step 6
    if (response.payload != null) {
      final docId = int.tryParse(response.payload!);
      if (docId != null) {
        ArkvioRouter.navigateToDocument(docId);
      }
    }
  }

  /// Show an immediate notification for a document deadline
  static Future<void> showDeadlineNotification({
    required int documentId,
    required String documentTitle,
    required int daysLeft,
  }) async {
    await initialize();

    final String body = daysLeft == 0
        ? 'Срок истекает сегодня'
        : daysLeft == 1
            ? 'Срок истекает завтра'
            : 'Осталось $daysLeft дн.';

    await _plugin.show(
      documentId, // notification id = document id
      documentTitle,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'arkvio_deadlines',
          'Сроки документов',
          channelDescription: 'Напоминания о дедлайнах документов',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: documentId.toString(),
    );
  }

  /// Request POST_NOTIFICATIONS permission (Android 13+)
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }
}
```

---

## Step 4 — Router helper for notification tap

### `lib/core/navigation/arkvio_router.dart`

Create a global navigator key and a helper to navigate from outside the widget tree (needed for notification taps):

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArkvioRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToDocument(int documentId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).push('/document/$documentId');
    }
  }
}
```

In `app.dart`, pass the navigator key to `GoRouter`:
```dart
final router = GoRouter(
  navigatorKey: ArkvioRouter.navigatorKey,
  // ... existing routes
);
```

---

## Step 5 — WorkManager task

### `lib/core/services/deadline_checker_task.dart`

```dart
import 'package:workmanager/workmanager.dart';
import 'package:drift_flutter/drift_flutter.dart';
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
```

Add `getDocumentsWithDeadlines()` to `DocumentsDao`:
```dart
Future<List<Document>> getDocumentsWithDeadlines() {
  return (select(documents)
    ..where((d) => d.deadlineAt.isNotNull())
    ..orderBy([(d) => OrderingTerm.asc(d.deadlineAt)]))
    .get();
}
```

---

## Step 6 — Initialize everything in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/notification_service.dart';
import 'core/services/deadline_checker_task.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.initialize();
  await NotificationService.requestPermission();

  // Initialize WorkManager with the background callback
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Register daily deadline check at 09:00
  await Workmanager().registerPeriodicTask(
    kDeadlineCheckTask,
    kDeadlineCheckTask,
    frequency: const Duration(hours: 24),
    initialDelay: _initialDelayUntil9am(),
    constraints: Constraints(networkType: NetworkType.not_required),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  runApp(const ProviderScope(child: ArkvioApp()));
}

/// Calculate delay until next 09:00
Duration _initialDelayUntil9am() {
  final now = DateTime.now();
  var next9am = DateTime(now.year, now.month, now.day, 9, 0);
  if (now.isAfter(next9am)) {
    next9am = next9am.add(const Duration(days: 1));
  }
  return next9am.difference(now);
}
```

---

## Step 7 — Deadlines Screen

Replace the existing placeholder at `lib/features/deadlines/deadlines_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'deadlines_provider.dart';
import '../../shared/utils/deadline_utils.dart';

class DeadlinesScreen extends ConsumerWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsWithDeadlinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Сроки')),
      body: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Нет документов с дедлайнами',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'При загрузке файла установите срок,\nи он появится здесь',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Group by urgency
          final now = DateTime.now();
          final overdue = docs.where((d) => d.deadlineAt!.isBefore(now)).toList();
          final urgent = docs.where((d) {
            final days = d.deadlineAt!.difference(now).inDays;
            return days >= 0 && days <= 14;
          }).toList();
          final upcoming = docs.where((d) {
            final days = d.deadlineAt!.difference(now).inDays;
            return days > 14;
          }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              if (overdue.isNotEmpty) ...[
                _SectionHeader(title: 'Просрочено', color: Colors.red.shade700),
                ...overdue.map((d) => _DeadlineTile(document: d)),
                const SizedBox(height: 12),
              ],
              if (urgent.isNotEmpty) ...[
                _SectionHeader(title: 'Скоро — до 14 дней', color: Colors.orange.shade700),
                ...urgent.map((d) => _DeadlineTile(document: d)),
                const SizedBox(height: 12),
              ],
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: 'Предстоящие', color: Colors.green.shade700),
                ...upcoming.map((d) => _DeadlineTile(document: d)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final dynamic document; // Document type from drift
  const _DeadlineTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final deadline = document.deadlineAt as DateTime;
    final daysLeft = deadline.difference(now).inDays;
    final isOverdue = deadline.isBefore(now);

    final Color barColor;
    final String daysLabel;
    if (isOverdue) {
      barColor = Colors.red;
      daysLabel = 'Просрочено';
    } else if (daysLeft == 0) {
      barColor = Colors.red;
      daysLabel = 'Сегодня';
    } else if (daysLeft == 1) {
      barColor = Colors.red;
      daysLabel = 'Завтра';
    } else if (daysLeft <= 14) {
      barColor = Colors.orange;
      daysLabel = '$daysLeft дн.';
    } else {
      barColor = Colors.green;
      daysLabel = '$daysLeft дн.';
    }

    final dateFormatted = DateFormat('d MMM yyyy', 'ru').format(deadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => GoRouter.of(context).push('/document/${document.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 44,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Срок: $dateFormatted',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                daysLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: barColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Step 8 — Deadlines Provider

### `lib/features/deadlines/deadlines_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';

part 'deadlines_provider.g.dart';

@riverpod
Stream<List<Document>> documentsWithDeadlines(DocumentsWithDeadlinesRef ref) {
  return ref.watch(appDatabaseProvider).documentsDao.watchDocumentsWithDeadlines();
}
```

Add `watchDocumentsWithDeadlines()` to `DocumentsDao`:
```dart
Stream<List<Document>> watchDocumentsWithDeadlines() {
  return (select(documents)
    ..where((d) => d.deadlineAt.isNotNull())
    ..where((d) => d.status.isNotValue('done'))
    ..orderBy([(d) => OrderingTerm.asc(d.deadlineAt)]))
    .watch();
}
```

---

## Step 9 — Run build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Testing checklist

- [ ] Open app → permission dialog for notifications appears (Android 13+)
- [ ] Upload a document, set deadline to today or tomorrow → go to Сроки tab → it appears in red section
- [ ] Upload a document with deadline in 20 days → appears in Предстоящие (green)
- [ ] Tap a deadline item → opens DocumentDetailScreen for that document
- [ ] Overdue documents (deadline in the past) → appear in Просрочено section
- [ ] Tap a notification (trigger manually via `adb shell am broadcast` or wait) → opens correct document

### Manual notification test (adb):
```bash
# Trigger WorkManager task immediately for testing
adb shell am broadcast -a androidx.work.impl.background.systemalarm.RescheduleReceiver
```
Or in code, temporarily add a test button that calls:
```dart
await Workmanager().registerOneOffTask('test', kDeadlineCheckTask);
```

---

## Known issues on some devices (Xiaomi / Huawei)

These manufacturers kill background processes aggressively. If WorkManager tasks don't fire:
- User must go to Settings → Battery → App → Arkvio → No restrictions
- Consider adding a one-time prompt in Phase 4 that detects the manufacturer and shows instructions

---

## What Phase 3 does NOT include

- Backup / export (Phase 4)
- Onboarding (Phase 4)
- Dark theme polish (Phase 4)
- Swipe gestures on list items (Phase 4)

---

## Report back after Phase 3

- Confirm notifications work on real device
- Report actual package versions used if different from above
- Note if WorkManager periodic task registered successfully (check with `adb shell dumpsys jobscheduler | grep arkvio`)
