import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.i('BOOTSTRAP', 'Starting Mas7ool Application...');

  // Initialize notifications
  try {
    await NotificationService.initialize();
  } catch (e, st) {
    AppLogger.e('BOOTSTRAP', 'NotificationService init error', e, st);
  }

  runApp(
    const ProviderScope(
      child: Mas7oolApp(),
    ),
  );
}
