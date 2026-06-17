import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/iraq_payment.dart';
import '../../data/gateways/fib_gateway.dart';
import '../../data/gateways/fastpay_gateway.dart';
import '../../data/gateways/nebula_gateway.dart';
import '../../data/gateways/payment_gateway.dart';
import '../../data/gateways/switch_gateway.dart';

final fibGatewayProvider = Provider<FibPaymentGateway>((_) => FibPaymentGateway());
final fastPayGatewayProvider =
    Provider<FastPayGateway>((_) => FastPayGateway());
final switchGatewayProvider =
    Provider<SwitchPaymentGateway>((_) => SwitchPaymentGateway());
final nebulaGatewayProvider =
    Provider<NebulaPaymentGateway>((_) => NebulaPaymentGateway());

final paymentGatewaysProvider = Provider<Map<IraqPaymentMethod, PaymentGateway>>((ref) {
  return {
    IraqPaymentMethod.fib: ref.watch(fibGatewayProvider),
    IraqPaymentMethod.fastpay: ref.watch(fastPayGatewayProvider),
    IraqPaymentMethod.switchGateway: ref.watch(switchGatewayProvider),
    IraqPaymentMethod.nebula: ref.watch(nebulaGatewayProvider),
  };
});

final selectedPaymentMethodProvider =
    StateProvider<IraqPaymentMethod>((_) => IraqPaymentMethod.fib);

class PaymentProcessor {
  PaymentProcessor(this._gateways);

  final Map<IraqPaymentMethod, PaymentGateway> _gateways;

  Future<PaymentResult> process(PaymentRequest request) async {
    final gateway = _gateways[request.method];
    if (gateway == null) {
      return PaymentResult.failure(
        request.method,
        'Desteklenmeyen ödeme yöntemi: ${request.method.code}',
      );
    }
    return gateway.pay(request);
  }
}

final paymentProcessorProvider = Provider<PaymentProcessor>((ref) {
  return PaymentProcessor(ref.watch(paymentGatewaysProvider));
});

final nebulaConnectionProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ref.watch(nebulaGatewayProvider).isConnected();
});
