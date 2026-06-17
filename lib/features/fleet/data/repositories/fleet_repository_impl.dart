import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/fleet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FleetRepositoryImpl implements FleetRepository {
  FleetRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Vehicle>> getVehicles({String? tenantId, String? status}) async {
    try {
      var query = _client
          .from('vehicles')
          .select()
          .eq('tenant_id', tenantId ?? AppConfig.demoTenantId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final data = await query.order('brand');
      return (data as List)
          .map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (AppConfig.useDemoFallback) return _demoVehicles;
      throw const NetworkException();
    }
  }

  @override
  Future<List<Branch>> getBranches({String? tenantId}) async {
    try {
      final data = await _client
          .from('branches')
          .select()
          .eq('tenant_id', tenantId ?? AppConfig.demoTenantId)
          .order('name');

      return (data as List)
          .map((e) => Branch.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (AppConfig.useDemoFallback) return Branch.demo;
      throw const NetworkException();
    }
  }

  static final _demoVehicles = [
    Vehicle(
      id: '30000000-0000-0000-0000-000000000001',
      tenantId: AppConfig.demoTenantId,
      plateNumber: '34 ABC 123',
      brand: 'BMW',
      model: '320i',
      categoryId: '20000000-0000-0000-0000-000000000002',
      categoryName: 'Sedan',
      dailyPrice: 1850,
      status: VehicleStatus.available,
      year: 2024,
      transmission: 'automatic',
      fuelType: 'petrol',
      features: ['GPS', 'Bluetooth', 'Deri Koltuk'],
      branchName: 'Merkez Şube',
    ),
    Vehicle(
      id: '30000000-0000-0000-0000-000000000002',
      tenantId: AppConfig.demoTenantId,
      plateNumber: '34 DEF 456',
      brand: 'Mercedes',
      model: 'GLC 200',
      categoryId: '20000000-0000-0000-0000-000000000003',
      categoryName: 'SUV',
      dailyPrice: 2400,
      status: VehicleStatus.available,
      year: 2023,
      transmission: 'automatic',
      branchName: 'Merkez Şube',
      features: ['AWD', 'Panoramik Tavan'],
    ),
    Vehicle(
      id: '30000000-0000-0000-0000-000000000003',
      tenantId: AppConfig.demoTenantId,
      plateNumber: '34 GHI 789',
      brand: 'Renault',
      model: 'Clio',
      categoryId: '20000000-0000-0000-0000-000000000001',
      categoryName: 'Ekonomi',
      dailyPrice: 650,
      status: VehicleStatus.rented,
      year: 2024,
      transmission: 'manual',
      branchName: 'Havalimanı',
    ),
    Vehicle(
      id: '30000000-0000-0000-0000-000000000004',
      tenantId: AppConfig.demoTenantId,
      plateNumber: '34 JKL 012',
      brand: 'Audi',
      model: 'A6',
      categoryId: '20000000-0000-0000-0000-000000000004',
      categoryName: 'Lüks',
      dailyPrice: 3200,
      status: VehicleStatus.available,
      year: 2024,
      transmission: 'automatic',
      features: ['Matrix LED'],
    ),
  ];
}
