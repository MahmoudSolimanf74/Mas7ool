import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/diagnostics/presentation/screens/diagnostics_screen.dart';
import 'features/main/presentation/screens/main_navigation_screen.dart';
import 'features/monitored_apps/presentation/screens/add_apps_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/onboarding/presentation/screens/permission_setup_screen.dart';
import 'features/settings/presentation/screens/device_compatibility_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionSetupScreen(),
    ),
    GoRoute(
      path: '/monitored-apps/add',
      builder: (context, state) => const AddAppsScreen(),
    ),
    GoRoute(
      path: '/settings/compatibility',
      builder: (context, state) => const DeviceCompatibilityScreen(),
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
