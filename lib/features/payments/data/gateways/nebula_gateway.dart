import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/iraq_payment.dart';
import 'payment_gateway.dart';

/// Nebula WebService — PAX POS terminal entegrasyonu.
/// Dokümantasyon: `Nebula Solution for all 20250820/`
///
/// Yerel WebService uç noktaları:
/// - POST /createRequest — Sale, PreAuth, Refund vb.
/// - GET  /isConnected — terminal bağlantı durumu
/// - POST /subscribe?replyURL= — callback kaydı
class NebulaPaymentGateway implements PaymentGateway {
  NebulaPaymentGateway({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  IraqPaymentMethod get method => IraqPaymentMethod.nebula;

  String get _baseUrl {
    var url = AppConfig.nebulaBaseUrl;
    if (!url.startsWith('http')) url = 'http://$url';
    return url;
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  /// Terminal bağlantı kontrolü.
  Future<bool> isConnected() async {
    try {
      final res = await _client
          .get(_uri('/isConnected'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Satış işlemi — `com.pax.payment.Sale`
  Future<Map<String, dynamic>> createSale({
    required int amount,
    String currencyCode = 'IQD',
    int tipAmount = 0,
  }) async {
    final body = jsonEncode({
      'CATEGORY': 'com.pax.payment.Sale',
      'parm': {
        'amount': amount,
        if (tipAmount > 0) 'tipAmount': tipAmount,
        'currencyCode': currencyCode,
      },
    });

    final res = await _client.post(
      _uri('/createRequest'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw NebulaException('createRequest failed: ${res.statusCode} ${res.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
  }

  /// Ön yetkilendirme — depozito için.
  Future<Map<String, dynamic>> createPreAuth({
    required int amount,
    String currencyCode = 'IQD',
  }) async {
    final body = jsonEncode({
      'CATEGORY': 'com.pax.payment.PreAuth',
      'parm': {
        'amount': amount,
        'currencyCode': currencyCode,
      },
    });

    final res = await _client.post(
      _uri('/createRequest'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw NebulaException('PreAuth failed: ${res.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
  }

  /// İşlem durumu sorgulama.
  Future<Map<String, dynamic>> queryStatus(int voucherNo) async {
    final body = jsonEncode({
      'CATEGORY': 'com.pax.payment.QueryStatus',
      'parm': {'voucherNo': voucherNo},
    });

    final res = await _client.post(
      _uri('/createRequest'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
  }

  /// Callback kaydı — Nebula dokümantasyonu
  Future<void> subscribe({required String replyUrl}) async {
    final uri = _uri('/subscribe', {'replyURL': replyUrl});
    await _client.post(uri);
  }

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    if (AppConfig.useDemoFallback) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      return PaymentResult.demoSuccess(method, request.referenceId);
    }

    try {
      final connected = await isConnected();
      if (!connected) {
        return PaymentResult.failure(
          method,
          'Nebula terminal bağlı değil. WebService çalışıyor mu? ($_baseUrl/isConnected)',
        );
      }

      final amountInt = request.amount.round();
      final response = await createSale(
        amount: amountInt,
        currencyCode: request.currencyCode,
      );

      return PaymentResult(
        success: true,
        method: method,
        transactionId: response['voucherNo']?.toString() ??
            response['transactionId']?.toString(),
        message: 'Nebula sale completed',
        rawResponse: response,
      );
    } on NebulaException catch (e) {
      return PaymentResult.failure(method, e.message);
    } catch (e) {
      return PaymentResult.failure(method, 'Nebula hatası: $e');
    }
  }
}

class NebulaException implements Exception {
  NebulaException(this.message);
  final String message;

  @override
  String toString() => message;
}
