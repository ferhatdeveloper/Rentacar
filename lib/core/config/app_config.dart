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
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vIn0.8B3F6k3Q9xY2Z1W4V7U0T5R8S1P4O7N0M3L6K9J2H5G',
  );

  static const demoTenantId = '00000000-0000-0000-0000-000000000001';
  static const demoTenantSlug = 'premium-rent';

  static bool get useDemoFallback => const bool.fromEnvironment(
        'USE_DEMO_FALLBACK',
        defaultValue: true,
      );
}
