import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/fleet_repository_impl.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/fleet_repository.dart';

final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  return FleetRepositoryImpl(ref.watch(supabaseClientProvider));
});

final vehicleListProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  final repo = ref.watch(fleetRepositoryProvider);
  return repo.getVehicles();
});

final availableVehiclesProvider =
    FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  final repo = ref.watch(fleetRepositoryProvider);
  return repo.getVehicles(status: 'available');
});

final branchListProvider = FutureProvider.autoDispose<List<Branch>>((ref) async {
  final repo = ref.watch(fleetRepositoryProvider);
  return repo.getBranches();
});
