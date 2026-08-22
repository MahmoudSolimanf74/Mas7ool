import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static final List<String> diagnosticLogs = [];

  static void i(String tag, String message) {
    final entry = '[$tag] $message';
    _logger.i(entry);
    _appendDiagnostic(entry);
  }

  static void w(String tag, String message) {
    final entry = '[$tag] WARN: $message';
    _logger.w(entry);
    _appendDiagnostic(entry);
  }

  static void e(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    final entry = '[$tag] ERROR: $message';
    _logger.e(entry, error: error, stackTrace: stackTrace);
    _appendDiagnostic('$entry ${error != null ? "($error)" : ""}');
  }

  static void d(String tag, String message) {
    final entry = '[$tag] DEBUG: $message';
    _logger.d(entry);
    _appendDiagnostic(entry);
  }

  static void _appendDiagnostic(String entry) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    diagnosticLogs.insert(0, '$time $entry');
    if (diagnosticLogs.length > 200) {
      diagnosticLogs.removeLast();
    }
  }

  static void clearDiagnostics() {
    diagnosticLogs.clear();
  }
}
