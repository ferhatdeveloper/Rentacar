import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/rental_repository_impl.dart';
import '../../domain/entities/rental.dart';
import '../../domain/repositories/rental_repository.dart';

final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  return RentalRepositoryImpl(ref.watch(supabaseClientProvider));
});

final rentalListProvider = FutureProvider.autoDispose<List<Rental>>((ref) async {
  final repo = ref.watch(rentalRepositoryProvider);
  return repo.getRentals();
});

final dashboardStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(rentalRepositoryProvider);
  return repo.getDashboardStats();
});

class BookingNotifier extends AutoDisposeAsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async => null;

  Future<RentalPriceQuote> calculatePrice({
    required String categoryId,
    required DateTime pickupAt,
    required DateTime returnAt,
  }) {
    return ref.read(rentalRepositoryProvider).calculatePrice(
          categoryId: categoryId,
          pickupAt: pickupAt,
          returnAt: returnAt,
        );
  }

  Future<void> submit(CreateRentalRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(rentalRepositoryProvider).createRental(request);
      ref.invalidate(rentalListProvider);
      ref.invalidate(dashboardStatsProvider);
      return result;
    });
  }
}

final bookingNotifierProvider =
    AutoDisposeAsyncNotifierProvider<BookingNotifier, Map<String, dynamic>?>(
  BookingNotifier.new,
);
