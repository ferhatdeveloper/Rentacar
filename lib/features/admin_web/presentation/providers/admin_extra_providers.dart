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
      return _demoInvoices;
    }
    rethrow;
  }
});

Map<String, dynamic> _invoice(
  int i,
  String date,
  String title,
  double total,
  double vat,
) =>
    {
      'id': '$i',
      'created_at': date,
      'branch': 'MERKEZ',
      'type': 'Satış Faturası',
      'invoice_number': 'ADV2026${i.toString().padLeft(8, '0')}',
      'e_doc_no': 'ADV2026${i.toString().padLeft(8, '0')}',
      'title': title,
      'status': 'Gönderildi',
      'total_amount': total,
      'vat_amount': vat,
      'grand_total': total + vat,
    };

final _demoInvoices = <Map<String, dynamic>>[
  _invoice(1, '2026-05-15', 'HAWKAR AHMED TAHA', 65.00, 9.92),
  _invoice(2, '2026-05-22', 'BEYTULLAH TOK', 881.36, 158.64),
  _invoice(3, '2026-05-29', 'KEMAL DAYAN', 120.00, 0.00),
  _invoice(4, '2026-05-31', 'HAERESCH SAFARI', 1100.01, 0.00),
  _invoice(5, '2026-06-02', 'YASIN DUMAN', 380.00, 0.00),
  _invoice(6, '2026-06-03', 'HAERESCH SAFARI', 400.00, 0.00),
  _invoice(7, '2026-06-09', 'ROBIN HARTYOM BOGHOS', 300.00, 0.00),
  _invoice(8, '2026-06-10', 'SARMAD KAMIL ABDULHADI', 280.00, 0.00),
  _invoice(9, '2026-06-11', 'HALMAT ASSAD HASAN', 395.00, 0.00),
  _invoice(10, '2026-06-10', 'KAWTHAR OTHMAN', 795.00, 0.00),
  _invoice(11, '2026-06-13', 'RIDVAN ŞİMŞEK', 750.00, 0.00),
  _invoice(12, '2026-06-14', 'MUHAMMAD KINAN MTALAL', 380.00, 0.00),
  _invoice(13, '2026-06-16', 'MUSTAFA SAMIR MOHAMMED', 1650.00, 0.00),
  _invoice(14, '2026-06-17', 'HASAN YILDIRIM', 290.00, 0.00),
  _invoice(15, '2026-06-18', 'RASHID DAOUD', 720.76, 129.74),
];
