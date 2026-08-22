import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInitSettings);

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          AppLogger.i('NOTIFICATION', 'Notification tapped: ${details.payload}');
        },
      );
    } catch (e, st) {
      AppLogger.e('NOTIFICATION', 'Failed to initialize notifications', e, st);
    }
  }

  static Future<void> showSessionExpiredNotification({
    required String appName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.sessionAlertChannelId,
      'تنبيهات انتهاء وقت الجلسة',
      channelDescription: 'إشعارات تنبيهية عند انتهاء وقت استخدام التطبيق المحدد',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        2001,
        'انتهى الوقت المحدد!',
        'لقد استنفدت وقت استخدام تطبيق $appName. حان وقت أخذ استراحة.',
        details,
        payload: appName,
      );
    } catch (e) {
      AppLogger.w('NOTIFICATION', 'Could not show notification: $e');
    }
  }
}
