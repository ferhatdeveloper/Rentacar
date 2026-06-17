import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(supabaseClientProvider));
});

final paymentListProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  return ref.watch(paymentRepositoryProvider).getPayments();
});

final revenueReportProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final client = ref.watch(supabaseClientProvider);
    final result = await client.rpc('get_revenue_report', params: {
      'p_tenant_id': AppConfig.demoTenantId,
      'p_days': 30,
    });
    return Map<String, dynamic>.from(result as Map);
  } catch (_) {
    return {
      'total_revenue': 124500,
      'rental_count': 47,
      'avg_daily_rate': 2648,
      'period_days': 30,
    };
  }
});
