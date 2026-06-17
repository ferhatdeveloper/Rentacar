import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/providers/app_providers.dart';

class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(tenantBrandingProvider);

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
                    Text('Firma Bilgileri',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.md),
                    _SettingRow(label: 'Firma Adı', value: branding.name),
                    _SettingRow(label: 'Slug', value: branding.slug),
                    _SettingRow(label: 'Tenant ID', value: AppConfig.demoTenantId),
                    _SettingRow(label: 'API URL', value: AppConfig.apiUrl),
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
                    Text('Entegrasyonlar',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.md),
                    const ListTile(
                      leading: Icon(Icons.payment),
                      title: Text('iyzico Ödeme'),
                      subtitle: Text('Yapılandırma bekliyor'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const ListTile(
                      leading: Icon(Icons.receipt_long),
                      title: Text('e-Fatura / e-Arşiv'),
                      subtitle: Text('GİB entegratör bağlantısı'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const ListTile(
                      leading: Icon(Icons.sms),
                      title: Text('SMS Bildirimleri'),
                      subtitle: Text('Netgsm / İleti Merkezi'),
                      trailing: Icon(Icons.chevron_right),
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
