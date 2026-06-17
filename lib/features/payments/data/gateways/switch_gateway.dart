import '../../../../core/config/app_config.dart';
import '../../domain/entities/iraq_payment.dart';
import 'payment_gateway.dart';
import 'payment_http_client.dart';

class SwitchPaymentGateway implements PaymentGateway {
  SwitchPaymentGateway({PaymentHttpClient? http}) : _http = http ?? PaymentHttpClient();

  final PaymentHttpClient _http;

  @override
  IraqPaymentMethod get method => IraqPaymentMethod.switchGateway;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    if (AppConfig.switchApiUrl.isEmpty || AppConfig.useDemoFallback) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return PaymentResult.demoSuccess(method, request.referenceId);
    }

    try {
      final res = await _http.postJson(
        baseUrl: AppConfig.switchApiUrl,
        path: '/payments/initiate',
        body: {
          'amount': request.amount.round(),
          'currency': request.currencyCode,
          'merchant_reference': request.referenceId,
          'customer_email': request.customerEmail,
        },
      );
      return PaymentResult(
        success: true,
        method: method,
        transactionId: res['payment_id']?.toString(),
        rawResponse: res,
      );
    } catch (e) {
      return PaymentResult.failure(method, 'Switch: $e');
    }
  }
}
