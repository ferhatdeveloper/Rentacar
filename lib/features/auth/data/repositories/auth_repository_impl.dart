import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;
  static const _sessionKey = 'rentacar_auth_session';

  @override
  Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _userFromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _client.rpc('login_tenant_user', params: {
        'p_tenant_id': AppConfig.demoTenantId,
        'p_email': email.trim(),
        'p_password': password,
      });
      final map = Map<String, dynamic>.from(result as Map);
      final user = _userFromMap(map);
      await _saveSession(user);
      return user;
    } catch (_) {
      if (AppConfig.useDemoFallback &&
          email == DemoCredentials.email &&
          password == DemoCredentials.password) {
        final user = AuthUser.demo;
        await _saveSession(user);
        return user;
      }
      throw Exception('Geçersiz e-posta veya şifre');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _saveSession(AuthUser user) async {
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
  }

  AuthUser _userFromMap(Map<String, dynamic> map) => AuthUser(
        id: map['id'] as String,
        tenantId: map['tenant_id'] as String,
        email: map['email'] as String,
        fullName: map['full_name'] as String? ?? '',
        role: UserRole.fromValue(map['role'] as String? ?? 'staff'),
      );
}

abstract final class DemoCredentials {
  static const email = 'admin@premium-rent.com';
  static const password = 'admin123';
  static const tenantId = AppConfig.demoTenantId;
}
