import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Customer>> getCustomers({String? tenantId}) async {
    try {
      final data = await _client
          .from('customers')
          .select()
          .eq('tenant_id', tenantId ?? AppConfig.demoTenantId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => Customer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (AppConfig.useDemoFallback) return Customer.demoList;
      throw const NetworkException();
    }
  }

  @override
  Future<Customer> createCustomer(
    CreateCustomerRequest request, {
    String? tenantId,
  }) async {
    try {
      final result = await _client.rpc(
        'create_customer',
        params: request.toRpcParams(tenantId ?? AppConfig.demoTenantId),
      );
      final id = (result as Map)['id'] as String;
      return Customer(
        id: id,
        tenantId: tenantId ?? AppConfig.demoTenantId,
        firstName: request.firstName,
        lastName: request.lastName,
        email: request.email,
        phone: request.phone,
        identityNumber: request.identityNumber,
      );
    } catch (_) {
      if (AppConfig.useDemoFallback) {
        return Customer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tenantId: AppConfig.demoTenantId,
          firstName: request.firstName,
          lastName: request.lastName,
          email: request.email,
          phone: request.phone,
        );
      }
      throw const NetworkException();
    }
  }
}
