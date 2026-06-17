import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacar/core/formatters/currency_formatter.dart';
import 'package:rentacar/core/l10n/app_localizations.dart';
import 'package:rentacar/core/l10n/supported_locales.dart';

void main() {
  testWidgets('CurrencyFormatter IQD format', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: SupportedLocales.en,
        localizationsDelegates: const [AppLocalizations.delegate],
        home: Builder(
          builder: (context) {
            final text = CurrencyFormatter.format(150000, context);
            expect(text, contains('150000'));
            expect(text, contains('IQD'));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
