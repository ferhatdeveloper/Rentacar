import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

/// Beto Yazılım "Yeni Müşteri" ekranına benzer, sekmeli kapsamlı müşteri formu.
///
/// Sekmeler: Hesap Bilgileri · Sürücü Bilgileri · Pasaport · Kart · Belge Tara.
/// Demo backend nedeniyle yalnızca temel alanlar (ad, soyad, e-posta, telefon,
/// kimlik no) kaydedilir; diğer alanlar form bütünlüğü için toplanır.
class NewCustomerDialog extends ConsumerStatefulWidget {
  const NewCustomerDialog({super.key});

  @override
  ConsumerState<NewCustomerDialog> createState() => _NewCustomerDialogState();
}

class _NewCustomerDialogState extends ConsumerState<NewCustomerDialog> {
  final _formKey = GlobalKey<FormState>();

  // Hesap Bilgileri
  final _fullName = TextEditingController();
  final _workplace = TextEditingController();
  final _residence = TextEditingController();
  final _email = TextEditingController();
  final _web = TextEditingController();
  final _gsm = TextEditingController();
  final _homePhone = TextEditingController();
  final _workPhone = TextEditingController();
  final _fax = TextEditingController();
  final _taxOffice = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _tckn = TextEditingController();
  final _address = TextEditingController();

  String _accountKind = 'Şahıs';
  String _accountType = 'Kısa Dönem Müşteri';
  String _country = 'TÜRKİYE';
  String _invoiceType = 'individual';

  // Sürücü Bilgileri
  final _driverName = TextEditingController();
  final _driverTckn = TextEditingController();
  final _driverBirth = TextEditingController();
  final _driverFather = TextEditingController();
  final _licenseNo = TextEditingController();
  final _loyaltyCard = TextEditingController();
  bool _foreignLicense = false;

  // Pasaport
  final _passportNo = TextEditingController();
  final _passportPlace = TextEditingController();

  // Kart Bilgileri
  final _bankName = TextEditingController();
  final _cardHolder = TextEditingController();
  final _cardNo = TextEditingController();

  // Belge Tara
  String _documentType = 'Kimlik Belgesi';

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _fullName, _workplace, _residence, _email, _web, _gsm, _homePhone,
      _workPhone, _fax, _taxOffice, _city, _district, _tckn, _address,
      _driverName, _driverTckn, _driverBirth, _driverFather, _licenseNo,
      _loyaltyCard, _passportNo, _passportPlace, _bankName, _cardHolder, _cardNo,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final parts = _fullName.text.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    try {
      await ref.read(customerRepositoryProvider).createCustomer(
            CreateCustomerRequest(
              firstName: firstName,
              lastName: lastName,
              email: _email.text.trim(),
              phone: _gsm.text.trim(),
              identityNumber: _tckn.text.trim().isEmpty ? null : _tckn.text.trim(),
            ),
          );
      ref.invalidate(customerListProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Müşteri kaydedildi: ${_fullName.text.trim()}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1040,
          maxHeight: size.height * 0.9,
        ),
        child: DefaultTabController(
          length: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context),
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.navy,
                indicatorColor: AppColors.amber,
                tabs: [
                  Tab(text: 'Hesap Bilgileri'),
                  Tab(text: 'Sürücü Bilgileri'),
                  Tab(text: 'Pasaport Bilgileri'),
                  Tab(text: 'Kart Bilgileri'),
                  Tab(text: 'Belge Tara'),
                ],
              ),
              const Divider(height: 1),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    children: [
                      _accountTab(),
                      _driverTab(),
                      _passportTab(),
                      _cardTab(),
                      _scanTab(),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add_alt_1, color: AppColors.amber),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Yeni Müşteri',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  // ---- Tabs ----

  Widget _accountTab() {
    return _tabScroll([
      _sectionTitle('Hesap'),
      _row([
        _dropdown('H. Türü', _accountKind, const ['Şahıs', 'Şirket'],
            (v) => setState(() => _accountKind = v!)),
        _dropdown('Hesap Türü', _accountType,
            const ['Kısa Dönem Müşteri', 'Uzun Dönem Müşteri', 'Kurumsal'],
            (v) => setState(() => _accountType = v!)),
      ]),
      _row([
        _dropdown('Ülke', _country, const ['TÜRKİYE', 'IRAK', 'SURİYE', 'DİĞER'],
            (v) => setState(() => _country = v!)),
        _field('Adı Soyadı', _fullName, required: true),
      ]),
      _row([
        _field('Çalıştığı Yer', _workplace),
        _field('İkametgah Adresi', _residence),
      ]),
      _row([
        _field('E-Posta', _email, keyboard: TextInputType.emailAddress),
        _field('Web Sayfası', _web),
      ]),
      _row([
        _field('Gsm', _gsm, keyboard: TextInputType.phone),
        _field('Ev Tel', _homePhone, keyboard: TextInputType.phone),
      ]),
      _row([
        _field('İş Tel', _workPhone, keyboard: TextInputType.phone),
        _field('Faks', _fax, keyboard: TextInputType.phone),
      ]),
      const SizedBox(height: AppSpacing.md),
      _sectionTitle('Fatura Bilgileri'),
      Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: 'individual',
              groupValue: _invoiceType,
              onChanged: (v) => setState(() => _invoiceType = v!),
              title: const Text('Bireysel'),
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: 'corporate',
              groupValue: _invoiceType,
              onChanged: (v) => setState(() => _invoiceType = v!),
              title: const Text('Kurumsal'),
            ),
          ),
        ],
      ),
      _row([
        _field('Vergi Dairesi', _taxOffice),
        _field('T.C Kimlik No', _tckn,
            keyboard: TextInputType.number, maxLength: 11),
      ]),
      _row([
        _field('Şehir', _city),
        _field('İlçe', _district),
      ]),
      _field('Adres', _address, maxLines: 2),
    ]);
  }

  Widget _driverTab() {
    return _tabScroll([
      _sectionTitle('1. Sürücü Bilgileri'),
      _row([
        _field('T.C Kimlik No', _driverTckn,
            keyboard: TextInputType.number, maxLength: 11),
        _field('Sürücü Adı', _driverName),
      ]),
      _row([
        _field('Doğum Tarihi', _driverBirth, hint: 'GG.AA.YYYY'),
        _field('Baba Adı', _driverFather),
      ]),
      _row([
        _field('Ehliyet Sınıfı / No', _licenseNo),
        _field('Sadakat Kart No', _loyaltyCard),
      ]),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _foreignLicense,
        onChanged: (v) => setState(() => _foreignLicense = v),
        title: const Text('Yabancı Ehliyet'),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Müşteriniz her araç kiralamasında para puan kazanır. '
        'Sonrasında kazanılan para puanları avantaja dönüştürebilir.',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.textSecondary),
      ),
    ]);
  }

  Widget _passportTab() {
    return _tabScroll([
      _sectionTitle('Pasaport Bilgileri'),
      _row([
        _field('Pasaport No', _passportNo),
        _field('Verildiği Yer', _passportPlace),
      ]),
    ]);
  }

  Widget _cardTab() {
    return _tabScroll([
      _sectionTitle('Kart Bilgileri'),
      _row([
        _field('Banka Adı', _bankName),
        _field('Kart Sahibi', _cardHolder),
      ]),
      _field('Kart No', _cardNo, keyboard: TextInputType.number, maxLength: 19),
    ]);
  }

  Widget _scanTab() {
    return _tabScroll([
      _sectionTitle('Belge Tara'),
      for (final doc in const ['Kimlik Belgesi', 'Ehliyet Belgesi', 'Pasaport'])
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: doc,
          groupValue: _documentType,
          onChanged: (v) => setState(() => _documentType = v!),
          title: Text(doc),
        ),
      const SizedBox(height: AppSpacing.md),
      Center(
        child: Column(
          children: [
            Icon(Icons.scanner_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$_documentType taraması başlatıldı (demo)')),
                );
              },
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Taramayı Başlat'),
            ),
          ],
        ),
      ),
    ]);
  }

  // ---- Helpers ----

  Widget _tabScroll(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(children: children);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboard,
        inputFormatters: keyboard == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          counterText: '',
          isDense: true,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label gerekli' : null
            : null,
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
