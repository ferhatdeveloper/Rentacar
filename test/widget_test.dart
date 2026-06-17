import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rentacar/app/app.dart';

void main() {
  testWidgets('App loads home page', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RentacarApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Popüler Araçlar'), findsOneWidget);
  });
}
