import 'package:intl/intl.dart';

class TimeFormatter {
  /// Formats duration to mm:ss (e.g. "04:15")
  static String formatRemaining(Duration duration) {
    if (duration.isNegative) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Formats minutes into human-readable Arabic text
  static String formatMinutesArabic(int minutes) {
    if (minutes == 1) return 'دقيقة واحدة';
    if (minutes == 2) return 'دقيقتان';
    if (minutes >= 3 && minutes <= 10) return '$minutes دقائق';
    return '$minutes دقيقة';
  }

  /// Formats seconds into human-readable Arabic text
  static String formatSecondsArabic(int seconds) {
    if (seconds < 60) {
      if (seconds == 1) return 'ثانية واحدة';
      if (seconds == 2) return 'ثانيتان';
      if (seconds >= 3 && seconds <= 10) return '$seconds ثوانٍ';
      return '$seconds ثانية';
    }
    return formatMinutesArabic(seconds ~/ 60);
  }

  /// Formats DateTime into Arabic date & time (e.g. "22 أغسطس, 11:30 ص")
  static String formatDateTimeArabic(DateTime dateTime) {
    return DateFormat('d MMMM, hh:mm a', 'ar').format(dateTime);
  }
}
