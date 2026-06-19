import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../widgets/new_customer_dialog.dart';

enum _BalanceFilter { all, debtor, creditor }

class AdminCustomersPage extends ConsumerStatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  ConsumerState<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends ConsumerState<AdminCustomersPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _BalanceFilter _filter = _BalanceFilter.all;
  int? _sortCol;
  bool _sortAsc = true;

  static final _dateFmt = DateFormat('dd.MM.yyyy');
  static final _money = NumberFormat('#,##0.00', 'tr');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Customer> _apply(List<Customer> all) {
    final q = _query.trim().toLowerCase();
    return all.where((c) {
      final matchesQuery = q.isEmpty ||
          c.fullName.toLowerCase().contains(q) ||
          (c.email ?? '').toLowerCase().contains(q) ||
          (c.phone ?? '').toLowerCase().contains(q) ||
          (c.country ?? '').toLowerCase().contains(q);
      final matchesFilter = switch (_filter) {
        _BalanceFilter.all => true,
        _BalanceFilter.debtor => c.balance > 0,
        _BalanceFilter.creditor => c.balance < 0,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<Customer> _sort(List<Customer> rows) {
    final col = _sortCol;
    if (col == null) return rows;
    final sorted = [...rows];
    sorted.sort((a, b) {
      final c = switch (col) {
        0 => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
        1 => (a.country ?? '').toLowerCase().compareTo((b.country ?? '').toLowerCase()),
        2 => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        3 => (a.address ?? '').toLowerCase().compareTo((b.address ?? '').toLowerCase()),
        4 => (a.email ?? '').toLowerCase().compareTo((b.email ?? '').toLowerCase()),
        5 => (a.phone ?? '').compareTo(b.phone ?? ''),
        6 => a.debtTotal.compareTo(b.debtTotal),
        7 => a.creditTotal.compareTo(b.creditTotal),
        8 => a.balance.compareTo(b.balance),
        _ => 0,
      };
      return _sortAsc ? c : -c;
    });
    return sorted;
  }

  void _onSort(int col, bool asc) =>
      setState(() {
        _sortCol = col;
        _sortAsc = asc;
      });

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Müşteri Listesi',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const NewCustomerDialog(),
                ),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Yeni Müşteri'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          customersAsync.when(
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Expanded(
              child: AppEmptyState(
                title: 'Yüklenemedi',
                message: e.toString(),
                onRetry: () => ref.invalidate(customerListProvider),
              ),
            ),
            data: (all) {
              final rows = _sort(_apply(all));
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBar(rows.length),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: rows.isEmpty
                          ? const AppEmptyState(title: 'Müşteri bulunamadı')
                          : _table(rows),
                    ),
                  ],
                ),
              );
            },
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
              hintText: 'Ara: ad, e-posta, telefon, ülke',
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
        SegmentedButton<_BalanceFilter>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: _BalanceFilter.all, label: Text('Tümü')),
            ButtonSegment(value: _BalanceFilter.debtor, label: Text('Borçlu')),
            ButtonSegment(value: _BalanceFilter.creditor, label: Text('Alacaklı')),
          ],
          selected: {_filter},
          onSelectionChanged: (s) => setState(() => _filter = s.first),
        ),
        Text(
          '$count kayıt',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _table(List<Customer> rows) {
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
              sortColumnIndex: _sortCol,
              sortAscending: _sortAsc,
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
                DataColumn(label: const Text('Tarih'), onSort: _onSort),
                DataColumn(label: const Text('Ülke'), onSort: _onSort),
                DataColumn(label: const Text('Ünvan / Adı Soyadı'), onSort: _onSort),
                DataColumn(label: const Text('Ev Adresi'), onSort: _onSort),
                DataColumn(label: const Text('E-Posta'), onSort: _onSort),
                DataColumn(label: const Text('Gsm'), onSort: _onSort),
                DataColumn(label: const Text('Borç Toplam'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('Alacak Toplam'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('Bakiye'), numeric: true, onSort: _onSort),
                const DataColumn(label: Text('')),
              ],
              rows: [
                for (final c in rows)
                  DataRow(cells: [
                    DataCell(Text(c.createdAt != null ? _dateFmt.format(c.createdAt!) : '-')),
                    DataCell(Text(c.country ?? '-')),
                    DataCell(Row(
                      children: [
                        Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (c.isCorporate) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.business, size: 14, color: AppColors.textSecondary),
                        ],
                        if (c.isBlacklisted) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.block, size: 14, color: AppColors.danger),
                        ],
                      ],
                    )),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(c.address ?? '-', overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text(c.email ?? '-')),
                    DataCell(Text(c.phone ?? '-')),
                    DataCell(Text(_money.format(c.debtTotal))),
                    DataCell(Text(_money.format(c.creditTotal))),
                    DataCell(Text(
                      _money.format(c.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.balance > 0
                            ? AppColors.danger
                            : c.balance < 0
                                ? AppColors.success
                                : AppColors.textSecondary,
                      ),
                    )),
                    DataCell(IconButton(
                      tooltip: 'Düzenle',
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const NewCustomerDialog(),
                      ),
                    )),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
