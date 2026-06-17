import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _sessionKey = 'rentacar_auth_session';

  @override
  Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser(
        id: map['id'] as String,
        tenantId: map['tenant_id'] as String,
        email: map['email'] as String,
        fullName: map['full_name'] as String,
        role: UserRole.fromValue(map['role'] as String? ?? 'staff'),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    // Demo auth — production: Supabase Auth veya API RPC
    if (email == 'admin@premium-rent.com' && password == 'admin123') {
      const user = AuthUser.demo;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _sessionKey,
        jsonEncode({
          'id': user.id,
          'tenant_id': user.tenantId,
          'email': user.email,
          'full_name': user.fullName,
          'role': user.role.value,
        }),
      );
      return user;
    }
    throw Exception('Geçersiz e-posta veya şifre');
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}

/// Demo giriş bilgileri (geliştirme)
abstract final class DemoCredentials {
  static const email = 'admin@premium-rent.com';
  static const password = 'admin123';
  static const tenantId = AppConfig.demoTenantId;
}
