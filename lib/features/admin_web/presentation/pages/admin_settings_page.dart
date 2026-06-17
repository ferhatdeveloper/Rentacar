import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../payments/presentation/providers/iraq_payment_providers.dart';
import '../../../../shared/widgets/language_selector.dart';

class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(tenantBrandingProvider);
    final l10n = AppLocalizations.of(context);
    final nebulaStatus = ref.watch(nebulaConnectionProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ayarlar',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsRegionIraq,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.md),
                    _SettingRow(label: 'Firma Adı', value: branding.name),
                    _SettingRow(label: 'Para Birimi', value: AppConfig.currencyCode),
                    _SettingRow(label: 'Tenant ID', value: AppConfig.demoTenantId),
                    _SettingRow(label: 'API URL', value: AppConfig.apiUrl),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text(l10n.settingsLanguage,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: AppSpacing.lg),
                        const LanguageSelector(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsPaymentGateways,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.md),
                    const ListTile(
                      leading: Icon(Icons.account_balance_wallet),
                      title: Text('FIB'),
                      subtitle: Text('First Iraqi Bank — FIB_API_URL'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.flash_on),
                      title: Text('FastPay'),
                      subtitle: Text('FASTPAY_API_URL'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Switch'),
                      subtitle: Text('SWITCH_API_URL'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.point_of_sale),
                      title: const Text('Nebula POS'),
                      subtitle: Text('NEBULA_URL: ${AppConfig.nebulaBaseUrl}'),
                      trailing: nebulaStatus.when(
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
                        data: (ok) => Icon(
                          ok ? Icons.check_circle : Icons.cancel,
                          color: ok ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
