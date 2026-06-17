import 'dart:convert';

import 'package:http/http.dart' as http;

/// Irak ödeme geçitleri için ortak HTTP istemcisi.
class PaymentHttpClient {
  PaymentHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> postJson({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PaymentHttpException(res.statusCode, res.body);
    }

    if (res.body.isEmpty) return {'ok': true};
    return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
  }
}

class PaymentHttpException implements Exception {
  PaymentHttpException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'Payment HTTP $statusCode: $body';
}
