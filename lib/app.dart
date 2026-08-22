import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/diagnostics/presentation/screens/diagnostics_screen.dart';
import 'features/monitored_apps/presentation/screens/add_apps_screen.dart';
import 'features/monitored_apps/presentation/screens/monitored_apps_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/onboarding/presentation/screens/permission_setup_screen.dart';
import 'features/sessions/presentation/screens/session_history_screen.dart';
import 'features/settings/presentation/screens/device_compatibility_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionSetupScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/monitored-apps',
      builder: (context, state) => const MonitoredAppsScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddAppsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const SessionHistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'compatibility',
          builder: (context, state) => const DeviceCompatibilityScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/diagnostics',
      builder: (context, state) => const DiagnosticsScreen(),
    ),
  ],
);

class Mas7oolApp extends ConsumerWidget {
  const Mas7oolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'مسؤول',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
