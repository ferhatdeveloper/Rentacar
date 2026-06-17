import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/config/tenant_branding.dart';
import '../../../../core/providers/app_providers.dart';

class WebsiteSettingsPage extends ConsumerStatefulWidget {
  const WebsiteSettingsPage({super.key});

  @override
  ConsumerState<WebsiteSettingsPage> createState() => _WebsiteSettingsPageState();
}

class _WebsiteSettingsPageState extends ConsumerState<WebsiteSettingsPage> {
  final _heroTitleCtrl = TextEditingController();
  final _heroSubtitleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _fieldsLoaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _heroTitleCtrl.dispose();
    _heroSubtitleCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _loadFields(TenantBranding b) {
    if (_fieldsLoaded) return;
    _heroTitleCtrl.text = b.heroTitle;
    _heroSubtitleCtrl.text = b.heroSubtitle;
    _phoneCtrl.text = b.contactPhone ?? '';
    _fieldsLoaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(tenantBrandingProvider.notifier).save(
            heroTitle: _heroTitleCtrl.text.trim(),
            heroSubtitle: _heroSubtitleCtrl.text.trim(),
            contactPhone: _phoneCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(tenantBrandingProvider);
    _loadFields(branding);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Web Sitesi Ayarları',
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          TextField(
                            controller: _heroTitleCtrl,
                            decoration: const InputDecoration(labelText: 'Hero Başlık'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _heroSubtitleCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'Hero Alt Metin'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(labelText: 'Telefon'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _saving ? null : _save,
                            child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Önizleme', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [branding.primaryColor, branding.primaryColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(branding.name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _heroTitleCtrl.text,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _heroSubtitleCtrl.text,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
