import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/inspection_repository_impl.dart';

final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  return InspectionRepositoryImpl(ref.watch(supabaseClientProvider));
});

class CheckInOutNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Map<String, dynamic>> checkin({
    required String rentalId,
    required int km,
    required int fuel,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(inspectionRepositoryProvider).completeCheckin(
            rentalId: rentalId,
            kmReading: km,
            fuelLevel: fuel,
            notes: notes,
          );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkout({
    required String rentalId,
    required int km,
    required int fuel,
    double damageCost = 0,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(inspectionRepositoryProvider).completeCheckout(
            rentalId: rentalId,
            kmReading: km,
            fuelLevel: fuel,
            damageCost: damageCost,
            notes: notes,
          );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final checkInOutProvider =
    AutoDisposeAsyncNotifierProvider<CheckInOutNotifier, void>(
  CheckInOutNotifier.new,
);
