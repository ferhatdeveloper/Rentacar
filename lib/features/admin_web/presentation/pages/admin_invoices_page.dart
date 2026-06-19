import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../providers/admin_extra_providers.dart';
import '../widgets/grid_column_header.dart';

class AdminInvoicesPage extends ConsumerStatefulWidget {
  const AdminInvoicesPage({super.key});

  @override
  ConsumerState<AdminInvoicesPage> createState() => _AdminInvoicesPageState();
}

class _AdminInvoicesPageState extends ConsumerState<AdminInvoicesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _sortCol;
  bool _sortAsc = true;
  final Map<int, Set<String>> _colFilters = {};

  static final _money = NumberFormat('#,##0.00', 'tr');

  double _num(Map<String, dynamic> m, String key) =>
      (m[key] as num?)?.toDouble() ?? 0;

  String _date(Map<String, dynamic> m) {
    final raw = m['created_at']?.toString();
    final d = raw != null ? DateTime.tryParse(raw) : null;
    return d != null ? DateFormat('dd.MM.yyyy').format(d) : '-';
  }

  String _cellValue(int col, Map<String, dynamic> inv) => switch (col) {
        0 => _date(inv),
        1 => '${inv['branch'] ?? 'MERKEZ'}',
        2 => '${inv['type'] ?? 'Satış Faturası'}',
        3 => '${inv['invoice_number'] ?? '-'}',
        4 => '${inv['e_doc_no'] ?? '-'}',
        5 => '${inv['title'] ?? '-'}',
        6 => '${inv['status'] ?? '-'}',
        7 => _money.format(_num(inv, 'total_amount')),
        8 => _money.format(_num(inv, 'vat_amount')),
        9 => _money.format(_num(inv, 'grand_total')),
        _ => '',
      };

  List<String> _distinct(int col, List<Map<String, dynamic>> all) {
    final set = <String>{for (final inv in all) _cellValue(col, inv)};
    return set.toList()..sort();
  }

  List<Map<String, dynamic>> _applyColumnFilters(List<Map<String, dynamic>> rows) {
    if (_colFilters.values.every((s) => s.isEmpty)) return rows;
    return rows.where((inv) {
      for (final entry in _colFilters.entries) {
        if (entry.value.isEmpty) continue;
        if (!entry.value.contains(_cellValue(entry.key, inv))) return false;
      }
      return true;
    }).toList();
  }

  void _setColumnFilter(int col, Set<String> values) =>
      setState(() => _colFilters[col] = values);

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

  List<Map<String, dynamic>> _sort(List<Map<String, dynamic>> rows) {
    final col = _sortCol;
    if (col == null) return rows;
    const keys = [
      'created_at', 'branch', 'type', 'invoice_number', 'e_doc_no',
      'title', 'status', 'total_amount', 'vat_amount', 'grand_total',
    ];
    final key = keys[col];
    final numeric = col >= 7;
    final sorted = [...rows];
    sorted.sort((a, b) {
      final int c;
      if (numeric) {
        c = _num(a, key).compareTo(_num(b, key));
      } else {
        c = (a[key] ?? '').toString().toLowerCase().compareTo(
              (b[key] ?? '').toString().toLowerCase(),
            );
      }
      return _sortAsc ? c : -c;
    });
    return sorted;
  }

  void _toggleSort(int col) => setState(() {
        if (_sortCol == col) {
          _sortAsc = !_sortAsc;
        } else {
          _sortCol = col;
          _sortAsc = true;
        }
      });

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
                final rows = _sort(_applyColumnFilters(_apply(all)));
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
                          : _table(rows, all),
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
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              hintText: 'Ara: fatura başlığı veya no',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        Text(
          '$count kayıt',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  DataColumn _col(int index, String title, List<Map<String, dynamic>> all,
      {bool numeric = false}) {
    return DataColumn(
      numeric: numeric,
      label: GridColumnHeader(
        title: title,
        columnIndex: index,
        activeSortIndex: _sortCol,
        ascending: _sortAsc,
        onSort: _toggleSort,
        distinctValues: _distinct(index, all),
        selected: _colFilters[index] ?? const <String>{},
        onApply: (v) => _setColumnFilter(index, v),
      ),
    );
  }

  Widget _table(List<Map<String, dynamic>> rows, List<Map<String, dynamic>> all) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              dividerThickness: 0.4,
              headingRowColor: WidgetStatePropertyAll(
                Colors.black.withValues(alpha: 0.02),
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              columns: [
                _col(0, 'Tarih', all),
                _col(1, 'Şube', all),
                _col(2, 'Türü', all),
                _col(3, 'Fatura No', all),
                _col(4, 'E-Evrak Takip No', all),
                _col(5, 'Fatura Başlık', all),
                _col(6, 'Gönderim', all),
                _col(7, 'Toplam Tutar', all, numeric: true),
                _col(8, 'Kdv Tutar', all, numeric: true),
                _col(9, 'Genel Toplam', all, numeric: true),
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
