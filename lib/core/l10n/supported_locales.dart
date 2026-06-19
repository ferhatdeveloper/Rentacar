import 'package:flutter/material.dart';

/// Irak pazarı — Arapça, Türkçe, İngilizce, Kürtçe (Sorani).
abstract final class SupportedLocales {
  static const ar = Locale('ar');
  static const tr = Locale('tr');
  static const en = Locale('en');
  static const ckb = Locale('ckb');

  static const all = [ar, tr, en, ckb];

  static const defaultLocale = ar;

  static bool isRtl(Locale locale) =>
      locale.languageCode == 'ar' || locale.languageCode == 'ckb';

  static String languageCode(Locale locale) => locale.languageCode;

  static Locale? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return all.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => defaultLocale,
    );
  }

  static String displayName(String languageCode) => switch (languageCode) {
        'ar' => 'العربية',
        'tr' => 'Türkçe',
        'en' => 'English',
        'ckb' => 'کوردی (سۆرانی)',
        _ => languageCode,
      };

  /// Dil değiştirme butonları için kısa etiket.
  static String shortLabel(String languageCode) => switch (languageCode) {
        'ar' => 'AR',
        'tr' => 'TR',
        'en' => 'EN',
        'ckb' => 'KU',
        _ => languageCode.toUpperCase(),
      };
}
