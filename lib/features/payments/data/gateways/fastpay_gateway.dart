import '../../../../core/config/app_config.dart';
import '../../domain/entities/iraq_payment.dart';
import 'payment_gateway.dart';
import 'payment_http_client.dart';

class FastPayGateway implements PaymentGateway {
  FastPayGateway({PaymentHttpClient? http}) : _http = http ?? PaymentHttpClient();

  final PaymentHttpClient _http;

  @override
  IraqPaymentMethod get method => IraqPaymentMethod.fastpay;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    if (AppConfig.fastPayApiUrl.isEmpty || AppConfig.useDemoFallback) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return PaymentResult.demoSuccess(method, request.referenceId);
    }

    try {
      final res = await _http.postJson(
        baseUrl: AppConfig.fastPayApiUrl,
        path: '/api/pay',
        body: {
          'amount': request.amount.round(),
          'currency': request.currencyCode,
          'order_id': request.referenceId,
          'mobile': request.customerPhone,
        },
      );
      return PaymentResult(
        success: res['status'] == 'success' || res['success'] == true,
        method: method,
        transactionId: res['txn_id']?.toString(),
        message: res['message']?.toString(),
        rawResponse: res,
      );
    } catch (e) {
      return PaymentResult.failure(method, 'FastPay: $e');
    }
  }
}
