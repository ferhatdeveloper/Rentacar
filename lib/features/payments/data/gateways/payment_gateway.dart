import '../../domain/entities/iraq_payment.dart';

abstract interface class PaymentGateway {
  IraqPaymentMethod get method;

  Future<PaymentResult> pay(PaymentRequest request);
}
