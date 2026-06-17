import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/tenant_branding.dart';
import '../network/api_client.dart';

const _brandingCacheKey = 'tenant_branding_cache';

final tenantBrandingProvider = NotifierProvider<TenantBrandingNotifier, TenantBranding>(
  TenantBrandingNotifier.new,
);

class TenantBrandingNotifier extends Notifier<TenantBranding> {
  @override
  TenantBranding build() {
    _load();
    return TenantBranding.demo;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_brandingCacheKey);
    if (raw != null) {
      try {
        state = _fromJson(jsonDecode(raw) as Map<String, dynamic>);
        return;
      } catch (_) {}
    }

    try {
      final client = ref.read(supabaseClientProvider);
      final data = await client
          .from('tenant_branding')
          .select()
          .eq('tenant_id', AppConfig.demoTenantId)
          .maybeSingle();
      if (data != null) {
        state = _fromApi(Map<String, dynamic>.from(data));
        await _cache(state);
      }
    } catch (_) {
      /* demo fallback */
    }
  }

  Future<void> save({
    required String heroTitle,
    required String heroSubtitle,
    required String contactPhone,
    String? whatsappNumber,
  }) async {
    final updated = TenantBranding(
      tenantId: state.tenantId,
      name: state.name,
      slug: state.slug,
      primaryColor: state.primaryColor,
      accentColor: state.accentColor,
      heroTitle: heroTitle,
      heroSubtitle: heroSubtitle,
      contactPhone: contactPhone,
      whatsappNumber: whatsappNumber ?? state.whatsappNumber,
    );

    try {
      await ref.read(supabaseClientProvider).rpc('update_tenant_branding', params: {
        'p_tenant_id': AppConfig.demoTenantId,
        'p_hero_title': heroTitle,
        'p_hero_subtitle': heroSubtitle,
        'p_contact_phone': contactPhone,
        'p_whatsapp_number': whatsappNumber,
      });
    } catch (_) {
      if (!AppConfig.useDemoFallback) rethrow;
    }

    state = updated;
    await _cache(updated);
  }

  Future<void> _cache(TenantBranding b) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brandingCacheKey, jsonEncode(_toJson(b)));
  }

  TenantBranding _fromApi(Map<String, dynamic> j) => TenantBranding(
        tenantId: j['tenant_id'] as String? ?? AppConfig.demoTenantId,
        name: j['tenant_name'] as String? ?? TenantBranding.demo.name,
        slug: j['tenant_slug'] as String? ?? TenantBranding.demo.slug,
        primaryColor: _color(j['primary_color'] as String?, TenantBranding.demo.primaryColor),
        accentColor: _color(j['accent_color'] as String?, TenantBranding.demo.accentColor),
        heroTitle: j['hero_title'] as String? ?? TenantBranding.demo.heroTitle,
        heroSubtitle: j['hero_subtitle'] as String? ?? TenantBranding.demo.heroSubtitle,
        contactPhone: j['contact_phone'] as String?,
        whatsappNumber: j['whatsapp_number'] as String?,
      );

  TenantBranding _fromJson(Map<String, dynamic> j) => TenantBranding(
        tenantId: j['tenantId'] as String,
        name: j['name'] as String,
        slug: j['slug'] as String,
        heroTitle: j['heroTitle'] as String,
        heroSubtitle: j['heroSubtitle'] as String,
        contactPhone: j['contactPhone'] as String?,
        whatsappNumber: j['whatsappNumber'] as String?,
        primaryColor: Color(j['primaryColor'] as int),
        accentColor: Color(j['accentColor'] as int),
      );

  Map<String, dynamic> _toJson(TenantBranding b) => {
        'tenantId': b.tenantId,
        'name': b.name,
        'slug': b.slug,
        'heroTitle': b.heroTitle,
        'heroSubtitle': b.heroSubtitle,
        'contactPhone': b.contactPhone,
        'whatsappNumber': b.whatsappNumber,
        'primaryColor': b.primaryColor.toARGB32(),
        'accentColor': b.accentColor.toARGB32(),
      };

  Color _color(String? hex, Color fallback) {
    if (hex == null || hex.length < 7) return fallback;
    final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (v == null) return fallback;
    return Color(0xFF000000 | v);
  }
}
