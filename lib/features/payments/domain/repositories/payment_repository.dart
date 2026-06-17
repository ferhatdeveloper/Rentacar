import '../entities/payment.dart';

abstract interface class PaymentRepository {
  Future<List<Payment>> getPayments({String? tenantId});
  Future<Map<String, dynamic>> recordPayment({
    required String rentalId,
    required String customerId,
    required String type,
    required double amount,
    String method = 'card',
    String? tenantId,
  });
}
