import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/tenant_branding.dart';
import '../design_system/app_theme.dart';

final tenantBrandingProvider = Provider<TenantBranding>((ref) {
  return TenantBranding.demo;
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final publicThemeProvider = Provider<ThemeData>((ref) {
  final branding = ref.watch(tenantBrandingProvider);
  final mode = ref.watch(themeModeProvider);
  final brightness =
      mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  return AppTheme.build(
    primary: branding.primaryColor,
    accent: branding.accentColor,
    brightness: brightness,
  );
});

final adminThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == ThemeMode.dark ? AppTheme.adminDark : AppTheme.adminLight;
});
