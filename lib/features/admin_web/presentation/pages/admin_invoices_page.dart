import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../providers/admin_extra_providers.dart';

class AdminInvoicesPage extends ConsumerStatefulWidget {
  const AdminInvoicesPage({super.key});

  @override
  ConsumerState<AdminInvoicesPage> createState() => _AdminInvoicesPageState();
}

class _AdminInvoicesPageState extends ConsumerState<AdminInvoicesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static final _money = NumberFormat('#,##0.00', 'tr');

  double _num(Map<String, dynamic> m, String key) =>
      (m[key] as num?)?.toDouble() ?? 0;

  String _date(Map<String, dynamic> m) {
    final raw = m['created_at']?.toString();
    final d = raw != null ? DateTime.tryParse(raw) : null;
    return d != null ? DateFormat('dd.MM.yyyy').format(d) : '-';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _apply(List<Map<String, dynamic>> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((inv) {
      return (inv['title'] ?? '').toString().toLowerCase().contains(q) ||
          (inv['invoice_number'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(invoiceListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fatura Listesi',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(title: 'Yüklenemedi', message: '$e'),
              data: (all) {
                final rows = _apply(all);
                final totalSum =
                    rows.fold<double>(0, (s, m) => s + _num(m, 'total_amount'));
                final vatSum =
                    rows.fold<double>(0, (s, m) => s + _num(m, 'vat_amount'));
                final grandSum =
                    rows.fold<double>(0, (s, m) => s + _num(m, 'grand_total'));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBar(rows.length),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: rows.isEmpty
                          ? const AppEmptyState(title: 'Fatura bulunamadı')
                          : _table(rows),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _totalsBar(totalSum, vatSum, grandSum),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Fatura başlığı veya fatura no...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count kayıt bulundu',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(List<Map<String, dynamic>> rows) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              columns: const [
                DataColumn(label: Text('Tarih')),
                DataColumn(label: Text('Şube')),
                DataColumn(label: Text('Türü')),
                DataColumn(label: Text('Fatura No')),
                DataColumn(label: Text('E-Evrak Takip No')),
                DataColumn(label: Text('Fatura Başlık')),
                DataColumn(label: Text('Gönderim')),
                DataColumn(label: Text('Toplam Tutar'), numeric: true),
                DataColumn(label: Text('Kdv Tutar'), numeric: true),
                DataColumn(label: Text('Genel Toplam'), numeric: true),
              ],
              rows: [
                for (final inv in rows)
                  DataRow(cells: [
                    DataCell(Text(_date(inv))),
                    DataCell(Text('${inv['branch'] ?? 'MERKEZ'}')),
                    DataCell(Text('${inv['type'] ?? 'Satış Faturası'}')),
                    DataCell(Text('${inv['invoice_number'] ?? '-'}')),
                    DataCell(Text('${inv['e_doc_no'] ?? '-'}')),
                    DataCell(Text(
                      '${inv['title'] ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )),
                    DataCell(_sentChip('${inv['status'] ?? ''}')),
                    DataCell(Text(_money.format(_num(inv, 'total_amount')))),
                    DataCell(Text(_money.format(_num(inv, 'vat_amount')))),
                    DataCell(Text(
                      _money.format(_num(inv, 'grand_total')),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sentChip(String status) {
    final sent = status.toLowerCase().contains('gönder');
    final color = sent ? AppColors.success : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _totalsBar(double total, double vat, double grand) {
    return Card(
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.end,
          children: [
            _totalItem('Toplam Tutar', total),
            _totalItem('Kdv Toplam', vat),
            _totalItem('Genel Toplam', grand, highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _totalItem(String label, double value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          '${_money.format(value)} TL',
          style: TextStyle(
            color: highlight ? AppColors.amberLight : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
