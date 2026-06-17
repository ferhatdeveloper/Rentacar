import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/app_theme.dart';
import 'branding_provider.dart';

export 'branding_provider.dart';

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
