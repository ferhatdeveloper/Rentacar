import 'package:flutter/material.dart';

import 'supported_locales.dart';
import 'translations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  String get _lang => locale.languageCode;

  String t(String key, {Map<String, String>? params}) {
    final langMap = Translations.data[_lang] ?? Translations.data['en']!;
    var value = langMap[key] ?? Translations.data['en']![key] ?? key;
    params?.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }

  // Nav
  String get navVehicles => t('nav_vehicles');
  String get navBooking => t('nav_booking');
  String get navRentNow => t('nav_rent_now');

  // Home
  String get heroTitle => t('hero_title');
  String get heroSubtitle => t('hero_subtitle');
  String get homePopularVehicles => t('home_popular_vehicles');
  String get homeSeeAll => t('home_see_all');
  String get homeVehiclesLoadError => t('home_vehicles_load_error');

  // Booking
  String get bookingTitle => t('booking_title');
  String get stepDateLocation => t('step_date_location');
  String get stepSelectVehicle => t('step_select_vehicle');
  String get stepDriverInfo => t('step_driver_info');
  String get stepPayment => t('step_payment');
  String get btnBack => t('btn_back');
  String get btnContinue => t('btn_continue');
  String get btnConfirmBooking => t('btn_confirm_booking');
  String get btnProcessing => t('btn_processing');

  String get formPickupBranch => t('form_pickup_branch');
  String get formReturnBranch => t('form_return_branch');
  String get formFullName => t('form_full_name');
  String get formEmail => t('form_email');
  String get formPhone => t('form_phone');
  String get formLicense => t('form_license');

  String get paymentSelectMethod => t('payment_select_method');
  String get paymentDepositNote => t('payment_deposit_note');
  String get paymentFibDesc => t('payment_fib_desc');
  String get paymentFastpayDesc => t('payment_fastpay_desc');
  String get paymentSwitchDesc => t('payment_switch_desc');
  String get paymentNebulaDesc => t('payment_nebula_desc');

  String get summaryTitle => t('summary_title');
  String summaryRentalDays(int days) =>
      t('summary_rental_days', params: {'days': '$days'});
  String get summaryTax => t('summary_tax');
  String get summaryDeposit => t('summary_deposit');
  String get summaryTotal => t('summary_total');
  String get summaryPricePending => t('summary_price_pending');
  String get bookingSuccess => t('booking_success');

  String get settingsLanguage => t('settings_language');
  String get settingsPaymentGateways => t('settings_payment_gateways');
  String get settingsRegionIraq => t('settings_region_iraq');
  String get currencyIqd => t('currency_iqd');

  List<String> get bookingSteps => [
        stepDateLocation,
        stepSelectVehicle,
        stepDriverInfo,
        stepPayment,
      ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      SupportedLocales.all
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final match = SupportedLocales.all.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => SupportedLocales.defaultLocale,
    );
    return AppLocalizations(match);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
