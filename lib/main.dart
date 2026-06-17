import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap.dart';
import 'app/app.dart';

void main() async {
  await bootstrap();
  runApp(const ProviderScope(child: RentacarApp()));
}
