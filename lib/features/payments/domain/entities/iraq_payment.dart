import 'package:equatable/equatable.dart';

/// Irak ödeme yöntemleri.
enum IraqPaymentMethod {
  fib('fib', 'FIB'),
  fastpay('fastpay', 'FastPay'),
  switchGateway('switch', 'Switch'),
  nebula('nebula', 'Nebula');

  const IraqPaymentMethod(this.code, this.displayName);

  final String code;
  final String displayName;

  static IraqPaymentMethod? fromCode(String? code) {
    if (code == null) return null;
    for (final m in values) {
      if (m.code == code) return m;
    }
    return null;
  }
}

class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.method,
    required this.amount,
    required this.currencyCode,
    required this.referenceId,
    this.description,
    this.customerPhone,
    this.customerEmail,
  });

  final IraqPaymentMethod method;
  final double amount;
  final String currencyCode;
  final String referenceId;
  final String? description;
  final String? customerPhone;
  final String? customerEmail;

  @override
  List<Object?> get props => [method, amount, referenceId];
}

class PaymentResult extends Equatable {
  const PaymentResult({
    required this.success,
    required this.method,
    this.transactionId,
    this.message,
    this.rawResponse,
  });

  final bool success;
  final IraqPaymentMethod method;
  final String? transactionId;
  final String? message;
  final Map<String, dynamic>? rawResponse;

  factory PaymentResult.demoSuccess(IraqPaymentMethod method, String ref) =>
      PaymentResult(
        success: true,
        method: method,
        transactionId: 'DEMO-${method.code}-$ref',
        message: 'Demo payment completed',
      );

  factory PaymentResult.failure(IraqPaymentMethod method, String message) =>
      PaymentResult(success: false, method: method, message: message);

  @override
  List<Object?> get props => [success, method, transactionId];
}
