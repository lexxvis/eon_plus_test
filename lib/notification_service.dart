import 'package:eon_plus_test/utils/consts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service class
class NotificationService {

  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    /// clear active notifications
    await _cancelAllNotifications();

    /// init Android notification setting
    const initializationSettingAndroid =
    AndroidInitializationSettings(notificationIcon);

    /// init iOS notification setting
    var initializationSettingIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSetting = InitializationSettings(
        android: initializationSettingAndroid, iOS: initializationSettingIOS);

    await notificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  /// show notification
  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName',
          importance: Importance.max),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> _cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

}
