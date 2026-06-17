import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/rental.dart';
import '../../domain/repositories/rental_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RentalRepositoryImpl implements RentalRepository {
  RentalRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Rental>> getRentals({String? tenantId}) async {
    try {
      final data = await _client
          .from('rentals')
          .select()
          .eq('tenant_id', tenantId ?? AppConfig.demoTenantId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Rental.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (AppConfig.useDemoFallback) return [];
      throw const NetworkException();
    }
  }

  @override
  Future<RentalPriceQuote> calculatePrice({
    required String categoryId,
    required DateTime pickupAt,
    required DateTime returnAt,
    String? tenantId,
  }) async {
    try {
      final result = await _client.rpc(
        'calculate_rental_price',
        params: {
          'p_tenant_id': tenantId ?? AppConfig.demoTenantId,
          'p_category_id': categoryId,
          'p_pickup_at': pickupAt.toUtc().toIso8601String(),
          'p_return_at': returnAt.toUtc().toIso8601String(),
        },
      );
      return RentalPriceQuote.fromJson(Map<String, dynamic>.from(result as Map));
    } catch (_) {
      if (AppConfig.useDemoFallback) {
        final days = returnAt.difference(pickupAt).inDays.clamp(1, 365);
        const daily = 1850.0;
        final base = daily * days;
        final tax = base * 0.2;
        return RentalPriceQuote(
          days: days,
          dailyPrice: daily,
          basePrice: base,
          taxAmount: tax,
          totalPrice: base + tax,
          depositAmount: 5000,
        );
      }
      throw const NetworkException();
    }
  }

  @override
  Future<Map<String, dynamic>> createRental(CreateRentalRequest request) async {
    try {
      final result = await _client.rpc(
        'create_rental',
        params: request.toRpcParams(AppConfig.demoTenantId),
      );
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw ApiException.fromPostgrest(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats({String? tenantId}) async {
    try {
      final result = await _client.rpc(
        'get_dashboard_stats',
        params: {'p_tenant_id': tenantId ?? AppConfig.demoTenantId},
      );
      return Map<String, dynamic>.from(result as Map);
    } catch (_) {
      if (AppConfig.useDemoFallback) {
        return {
          'active_rentals': 12,
          'today_pickups': 5,
          'today_returns': 3,
          'utilization_rate': 78.0,
          'monthly_revenue': 124500,
          'available_vehicles': 4,
          'total_vehicles': 6,
        };
      }
      throw const NetworkException();
    }
  }
}
