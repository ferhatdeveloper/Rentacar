import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import '../features/admin_web/router/admin_router.dart';
import '../features/public_web/router/public_router.dart';

enum AppMode { public, admin }

final appModeProvider = StateProvider<AppMode>((ref) {
  const envMode = String.fromEnvironment('APP_MODE', defaultValue: 'public');
  return envMode == 'admin' ? AppMode.admin : AppMode.public;
});

class RentacarApp extends ConsumerWidget {
  const RentacarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final theme = mode == AppMode.admin
        ? ref.watch(adminThemeProvider)
        : ref.watch(publicThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = mode == AppMode.admin ? adminRouter : publicRouter;

    return MaterialApp.router(
      title: mode == AppMode.admin ? 'Rentacar Admin' : 'Premium Rent',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: mode == AppMode.admin
          ? ref.watch(adminThemeProvider)
          : ref.watch(publicThemeProvider),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
