import '../entities/branch.dart';
import '../entities/vehicle.dart';

abstract interface class FleetRepository {
  Future<List<Vehicle>> getVehicles({String? tenantId, String? status});
  Future<List<Branch>> getBranches({String? tenantId});
}
