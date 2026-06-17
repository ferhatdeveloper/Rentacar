/// Uygulama yapılandırması — dart-define veya varsayılan değerler.
abstract final class AppConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// PostgREST anon JWT — docker-compose PGRST_JWT_SECRET ile imzalanmalı.
  static const anonKey = String.fromEnvironment(
    'ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiJ9.XDXylaELk-9NqFVRXss_uRpf_8qNrnWlBu8ExEpR_xQ',
  );

  static const demoTenantId = '00000000-0000-0000-0000-000000000001';
  static const demoTenantSlug = 'premium-rent';

  /// Irak bölgesi — varsayılan para birimi IQD.
  static const region = 'IQ';
  static const currencyCode = 'IQD';

  static bool get useDemoFallback => const bool.fromEnvironment(
        'USE_DEMO_FALLBACK',
        defaultValue: true,
      );

  /// Nebula WebService — yerel POS (varsayılan: localhost:9092)
  static const nebulaBaseUrl = String.fromEnvironment(
    'NEBULA_URL',
    defaultValue: 'localhost:9092',
  );

  static const fibApiUrl = String.fromEnvironment('FIB_API_URL', defaultValue: '');
  static const fibMerchantId =
      String.fromEnvironment('FIB_MERCHANT_ID', defaultValue: '');

  static const fastPayApiUrl =
      String.fromEnvironment('FASTPAY_API_URL', defaultValue: '');

  static const switchApiUrl =
      String.fromEnvironment('SWITCH_API_URL', defaultValue: '');
}
