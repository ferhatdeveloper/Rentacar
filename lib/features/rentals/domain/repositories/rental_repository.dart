import '../entities/rental.dart';

abstract interface class RentalRepository {
  Future<List<Rental>> getRentals({String? tenantId});
  Future<RentalPriceQuote> calculatePrice({
    required String categoryId,
    required DateTime pickupAt,
    required DateTime returnAt,
    String? tenantId,
  });
  Future<Map<String, dynamic>> createRental(CreateRentalRequest request);
  Future<Map<String, dynamic>> getDashboardStats({String? tenantId});
  Future<Map<String, dynamic>> cancelRental(String rentalId, {String? tenantId});
}
