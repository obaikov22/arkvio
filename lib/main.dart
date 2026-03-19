import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/notification_service.dart';
import 'core/services/deadline_checker_task.dart';
import 'core/services/whats_new_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await NotificationService.requestPermission();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  await Workmanager().registerPeriodicTask(
    kDeadlineCheckTask,
    kDeadlineCheckTask,
    frequency: const Duration(hours: 24),
    initialDelay: _initialDelayUntil9am(),
    constraints: Constraints(networkType: NetworkType.notRequired),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final showWhatsNew = await WhatsNewService.shouldShow();

  runApp(ProviderScope(
    child: ArkvioApp(
      onboardingDone: onboardingDone,
      showWhatsNew: showWhatsNew,
    ),
  ));
}

Duration _initialDelayUntil9am() {
  final now = DateTime.now();
  var next9am = DateTime(now.year, now.month, now.day, 9, 0);
  if (now.isAfter(next9am)) {
    next9am = next9am.add(const Duration(days: 1));
  }
  return next9am.difference(now);
}
