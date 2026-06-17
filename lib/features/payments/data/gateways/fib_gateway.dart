import '../../../../core/config/app_config.dart';
import '../../domain/entities/iraq_payment.dart';
import 'payment_gateway.dart';
import 'payment_http_client.dart';

class FibPaymentGateway implements PaymentGateway {
  FibPaymentGateway({PaymentHttpClient? http}) : _http = http ?? PaymentHttpClient();

  final PaymentHttpClient _http;

  @override
  IraqPaymentMethod get method => IraqPaymentMethod.fib;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    if (AppConfig.fibApiUrl.isEmpty || AppConfig.useDemoFallback) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return PaymentResult.demoSuccess(method, request.referenceId);
    }

    try {
      final res = await _http.postJson(
        baseUrl: AppConfig.fibApiUrl,
        path: '/v1/payments',
        headers: {
          if (AppConfig.fibMerchantId.isNotEmpty)
            'X-Merchant-Id': AppConfig.fibMerchantId,
        },
        body: {
          'amount': request.amount.round(),
          'currency': request.currencyCode,
          'reference': request.referenceId,
          'description': request.description ?? 'Rentacar rental',
          'customer_phone': request.customerPhone,
        },
      );
      return PaymentResult(
        success: true,
        method: method,
        transactionId: res['transaction_id']?.toString() ?? res['id']?.toString(),
        rawResponse: res,
      );
    } catch (e) {
      return PaymentResult.failure(method, 'FIB: $e');
    }
  }
}
