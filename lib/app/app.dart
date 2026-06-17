import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_localizations.dart';
import '../core/l10n/locale_provider.dart';
import '../core/l10n/supported_locales.dart';
import '../core/providers/app_providers.dart';
import '../features/admin_web/router/admin_router.dart';
import '../features/public_web/router/public_router.dart';

enum AppMode { public, admin }

final appModeProvider = StateProvider<AppMode>((ref) {
  const envMode = String.fromEnvironment('APP_MODE', defaultValue: 'public');
  return envMode == 'admin' ? AppMode.admin : AppMode.public;
});

/// Material/Cupertino `ckb` desteklemez — Arapça fallback.
Locale _frameworkLocale(Locale userLocale) {
  if (userLocale.languageCode == 'ckb') return SupportedLocales.ar;
  return userLocale;
}

class RentacarApp extends ConsumerWidget {
  const RentacarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final userLocale = ref.watch(localeProvider);
    final frameworkLocale = _frameworkLocale(userLocale);
    final isRtl = SupportedLocales.isRtl(userLocale);
    final theme = mode == AppMode.admin
        ? ref.watch(adminThemeProvider)
        : ref.watch(publicThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = mode == AppMode.admin ? adminRouter : publicRouter;

    return MaterialApp.router(
      title: mode == AppMode.admin ? 'Rentacar Admin' : 'Premium Rent',
      debugShowCheckedModeBanner: false,
      locale: frameworkLocale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      darkTheme: mode == AppMode.admin
          ? ref.watch(adminThemeProvider)
          : ref.watch(publicThemeProvider),
      themeMode: themeMode,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: userLocale,
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: router,
    );
  }
}
