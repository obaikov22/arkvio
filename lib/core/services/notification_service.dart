import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../navigation/arkvio_router.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

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
      documentId,
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
