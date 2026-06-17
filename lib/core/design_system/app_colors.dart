import 'package:flutter/material.dart';

abstract final class AppColors {
  // Premium Mobility palette
  static const navy = Color(0xFF0B1F3A);
  static const navyLight = Color(0xFF1A3A5C);
  static const amber = Color(0xFFE8A317);
  static const amberLight = Color(0xFFF5C842);
  static const surfaceLight = Color(0xFFF7F8FA);
  static const surfaceDark = Color(0xFF0A1628);
  static const cardDark = Color(0xFF122038);

  static const success = Color(0xFF0D9488);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textOnDark = Color(0xFFF9FAFB);

  static Color withTenantPrimary(Color? tenantPrimary) =>
      tenantPrimary ?? navy;

  static Color withTenantAccent(Color? tenantAccent) =>
      tenantAccent ?? amber;
}
