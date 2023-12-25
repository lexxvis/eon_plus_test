import 'package:eon_plus_test/utils/consts.dart';
import 'package:eon_plus_test/utils/strings.dart';
import 'package:eon_plus_test/water_reminder_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';

/// callback is invoked periodically by workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ///show notification message
    NotificationService().showNotification(
        title: Strings.notifTitle,
        body: Strings.notifBody
    );

    /// get saved date&time limit and endlessly flag
    final prefs = await SharedPreferences.getInstance();
    final endDate = DateTime.parse(prefs.getString(sharedPrefEndDateKey)!);
    final endlessly = prefs.getBool(sharedPrefEndlessKey) ?? false;

    /// if endlessly isn't set up, check date limit
    if (!endlessly) {
      if (DateTime.now().compareTo(endDate) > 0) {
        /// stop Workmanager
        Workmanager().cancelAll();
      }
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  NotificationService().initNotification();
  /// clear active Workmanager
  Workmanager().cancelAll();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.akayaKanadaka().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WaterReminderPage(),
    );
  }
}

