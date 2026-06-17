import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final apiReadyProvider = FutureProvider<bool>((ref) async {
  try {
    final client = ref.read(supabaseClientProvider);
    await client.from('vehicles').select('id').limit(1);
    return true;
  } catch (_) {
    return false;
  }
});

Future<void> initializeApi() async {
  await Supabase.initialize(
    url: AppConfig.apiUrl,
    publishableKey: AppConfig.anonKey,
    postgrestOptions: const PostgrestClientOptions(schema: 'api'),
  );
}
