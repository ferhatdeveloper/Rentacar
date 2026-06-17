import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';

final maintenanceListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final data = await ref.watch(supabaseClientProvider)
        .from('maintenance')
        .select()
        .eq('tenant_id', AppConfig.demoTenantId)
        .order('scheduled_at', ascending: false);
    return (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    if (AppConfig.useDemoFallback) {
      return [
        {
          'id': '1',
          'plate_number': '34 ABC 123',
          'brand': 'BMW',
          'model': '320i',
          'type': 'periodic',
          'description': 'Yağ değişimi',
          'status': 'scheduled',
          'scheduled_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        },
      ];
    }
    rethrow;
  }
});

Future<void> createMaintenanceRecord({
  required WidgetRef ref,
  required String vehicleId,
  required String description,
  String type = 'periodic',
}) async {
  try {
    await ref.read(supabaseClientProvider).rpc('create_maintenance', params: {
      'p_tenant_id': AppConfig.demoTenantId,
      'p_vehicle_id': vehicleId,
      'p_type': type,
      'p_description': description,
    });
  } catch (_) {
    if (!AppConfig.useDemoFallback) rethrow;
  }
  ref.invalidate(maintenanceListProvider);
}

final invoiceListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final data = await ref.watch(supabaseClientProvider)
        .from('invoices')
        .select()
        .eq('tenant_id', AppConfig.demoTenantId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    if (AppConfig.useDemoFallback) {
      return [
        {
          'id': '1',
          'invoice_number': 'INV-2026-00001',
          'total_amount': 6660,
          'status': 'issued',
        },
      ];
    }
    rethrow;
  }
});
