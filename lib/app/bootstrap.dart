import 'package:flutter/material.dart';

import '../core/network/api_client.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeApi();
  } catch (_) {
    // Demo fallback modunda API olmadan devam edilir.
  }
}
