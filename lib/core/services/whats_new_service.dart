import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewService {
  static const _key = 'lastSeenVersion';

  // ← Bump this every release to match pubspec.yaml version
  static const currentVersion = '1.0.1';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getString(_key) ?? '';
    return seen != currentVersion;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currentVersion);
  }
}
