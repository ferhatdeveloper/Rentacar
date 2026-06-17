import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Payment>> getPayments({String? tenantId}) async {
    try {
      final data = await _client
          .from('payments')
          .select()
          .eq('tenant_id', tenantId ?? AppConfig.demoTenantId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => Payment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (AppConfig.useDemoFallback) return _demo;
      throw const NetworkException();
    }
  }

  static final _demo = [
    Payment(
      id: '1',
      tenantId: AppConfig.demoTenantId,
      customerId: '40000000-0000-0000-0000-000000000001',
      type: 'rental',
      amount: 5550,
      status: PaymentStatus.completed,
      customerName: 'Ahmet Yılmaz',
      rentalNumber: 'RNT-2026-00001',
      paidAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Payment(
      id: '2',
      tenantId: AppConfig.demoTenantId,
      customerId: '40000000-0000-0000-0000-000000000001',
      type: 'deposit',
      amount: 5000,
      status: PaymentStatus.completed,
      customerName: 'Ahmet Yılmaz',
      rentalNumber: 'RNT-2026-00001',
    ),
  ];

  @override
  Future<Map<String, dynamic>> recordPayment({
    required String rentalId,
    required String customerId,
    required String type,
    required double amount,
    String method = 'card',
    String? tenantId,
  }) async {
    try {
      return Map<String, dynamic>.from(await _client.rpc('record_payment', params: {
            'p_tenant_id': tenantId ?? AppConfig.demoTenantId,
            'p_rental_id': rentalId,
            'p_customer_id': customerId,
            'p_type': type,
            'p_amount': amount,
            'p_method': method,
          }) as Map);
    } catch (_) {
      if (AppConfig.useDemoFallback) return {'id': 'demo', 'status': 'completed'};
      throw const NetworkException();
    }
  }
}
