class AppConstants {
  static const String appName = 'مسؤول';
  static const String appSubtitle = 'التحكم الذكي في وقت استخدام التطبيقات';

  // Native Channels
  static const String methodChannelName = 'com.mas7ool/native_bridge';
  static const String eventChannelName = 'com.mas7ool/monitoring_events';

  // Popular Social Apps presets with Package Names
  static const Map<String, String> popularSocialApps = {
    'com.instagram.android': 'Instagram',
    'com.facebook.katana': 'Facebook',
    'com.facebook.orca': 'Messenger',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.google.android.youtube': 'YouTube',
    'com.twitter.android': 'X (Twitter)',
    'com.snapchat.android': 'Snapchat',
    'com.reddit.frontpage': 'Reddit',
    'org.telegram.messenger': 'Telegram',
    'com.whatsapp': 'WhatsApp',
    'com.pinterest': 'Pinterest',
  };

  // Notification Channels
  static const String foregroundChannelId = 'mas7ool_monitoring_service_channel';
  static const String sessionAlertChannelId = 'mas7ool_session_alerts';

  // Default Durations
  static const List<int> defaultDurationOptions = [1, 5, 15];
  static const int extensionMinutes = 1;
}
