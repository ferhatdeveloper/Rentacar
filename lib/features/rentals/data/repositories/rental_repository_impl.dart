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
      if (AppConfig.useDemoFallback) return _demoRentals;
      throw const NetworkException();
    }
  }

  static final _demoRentals = [
    Rental(
      id: '60000000-0000-0000-0000-000000000001',
      tenantId: AppConfig.demoTenantId,
      rentalNumber: 'RNT-2026-00001',
      pickupAt: DateTime.now().add(const Duration(days: 1)),
      returnAt: DateTime.now().add(const Duration(days: 4)),
      status: RentalStatus.confirmed,
      customerName: 'Ahmet Yılmaz',
      brand: 'BMW',
      model: '320i',
      plateNumber: '34 ABC 123',
      totalPrice: 6660,
    ),
    Rental(
      id: '60000000-0000-0000-0000-000000000002',
      tenantId: AppConfig.demoTenantId,
      rentalNumber: 'RNT-2026-00002',
      pickupAt: DateTime.now().subtract(const Duration(days: 1)),
      returnAt: DateTime.now().add(const Duration(days: 2)),
      status: RentalStatus.active,
      customerName: 'Mehmet Demir',
      brand: 'Mercedes',
      model: 'GLC 200',
      plateNumber: '34 DEF 456',
      totalPrice: 8640,
    ),
  ];

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
      if (AppConfig.useDemoFallback) {
        return {
          'id': '60000000-0000-0000-0000-${DateTime.now().millisecondsSinceEpoch}',
          'rental_number': 'RNT-DEMO-${DateTime.now().millisecondsSinceEpoch % 100000}',
          'status': 'confirmed',
        };
      }
      throw ApiException.fromPostgrest(e);
    }
  }

  @override
  Future<Map<String, dynamic>> cancelRental(String rentalId, {String? tenantId}) async {
    try {
      return Map<String, dynamic>.from(await _client.rpc('cancel_rental', params: {
            'p_tenant_id': tenantId ?? AppConfig.demoTenantId,
            'p_rental_id': rentalId,
          }) as Map);
    } catch (_) {
      if (AppConfig.useDemoFallback) return {'id': rentalId, 'status': 'cancelled'};
      throw const NetworkException();
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
