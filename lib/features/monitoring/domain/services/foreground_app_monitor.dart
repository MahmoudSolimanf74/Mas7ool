import '../entities/foreground_event.dart';

abstract class ForegroundAppMonitor {
  Stream<ForegroundAppEvent> watch();
  Future<String?> getCurrentForegroundPackage();
}
