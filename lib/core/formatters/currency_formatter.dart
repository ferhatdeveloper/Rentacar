import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../l10n/app_localizations.dart';

abstract final class CurrencyFormatter {
  static String format(double amount, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final symbol = l10n.currencyIqd;
    final value = amount.toStringAsFixed(0);
    final locale = Localizations.localeOf(context);
    final isRtl = locale.languageCode == 'ar' || locale.languageCode == 'ckb';
    if (isRtl) return '$value $symbol';
    return '$symbol $value';
  }

  static String formatWithCode(double amount) =>
      '${amount.toStringAsFixed(0)} ${AppConfig.currencyCode}';
}
