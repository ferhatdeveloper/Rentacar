import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class InspectionRepository {
  Future<Map<String, dynamic>> completeCheckin({
    required String rentalId,
    required int kmReading,
    required int fuelLevel,
    String? notes,
    String? tenantId,
  });

  Future<Map<String, dynamic>> completeCheckout({
    required String rentalId,
    required int kmReading,
    required int fuelLevel,
    double damageCost = 0,
    String? notes,
    List<String> photoUrls = const [],
    String? tenantId,
  });
}

class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> completeCheckin({
    required String rentalId,
    required int kmReading,
    required int fuelLevel,
    String? notes,
    String? tenantId,
  }) async {
    try {
      return Map<String, dynamic>.from(await _client.rpc('complete_checkin', params: {
            'p_tenant_id': tenantId ?? AppConfig.demoTenantId,
            'p_rental_id': rentalId,
            'p_km_reading': kmReading,
            'p_fuel_level': fuelLevel,
            'p_notes': notes,
          }) as Map);
    } catch (_) {
      if (AppConfig.useDemoFallback) {
        return {'inspection_id': 'demo', 'status': 'active'};
      }
      throw const NetworkException();
    }
  }

  @override
  Future<Map<String, dynamic>> completeCheckout({
    required String rentalId,
    required int kmReading,
    required int fuelLevel,
    double damageCost = 0,
    String? notes,
    List<String> photoUrls = const [],
    String? tenantId,
  }) async {
    try {
      return Map<String, dynamic>.from(await _client.rpc('complete_checkout', params: {
            'p_tenant_id': tenantId ?? AppConfig.demoTenantId,
            'p_rental_id': rentalId,
            'p_km_reading': kmReading,
            'p_fuel_level': fuelLevel,
            'p_damage_cost': damageCost,
            'p_notes': notes,
            'p_photo_urls': photoUrls,
          }) as Map);
    } catch (_) {
      if (AppConfig.useDemoFallback) {
        return {'inspection_id': 'demo', 'status': 'returned'};
      }
      throw const NetworkException();
    }
  }
}
