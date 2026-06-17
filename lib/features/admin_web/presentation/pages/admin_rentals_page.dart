import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/formatters/currency_formatter.dart';
import '../../../rentals/domain/entities/rental.dart';
import '../../../rentals/presentation/providers/rental_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class AdminRentalsPage extends ConsumerWidget {
  const AdminRentalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentalsAsync = ref.watch(rentalListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rezervasyonlar', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: rentalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(
                title: 'Rezervasyonlar yüklenemedi',
                message: e.toString(),
                onRetry: () => ref.invalidate(rentalListProvider),
              ),
              data: (rentals) => _RentalsTable(rentals: rentals),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalsTable extends ConsumerWidget {
  const _RentalsTable({required this.rentals});

  final List<Rental> rentals;
  static final _dateFmt = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rentals.isEmpty) {
      return const AppEmptyState(title: 'Rezervasyon yok', message: 'Henüz kayıtlı rezervasyon bulunmuyor.');
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Müşteri')),
            DataColumn(label: Text('Araç')),
            DataColumn(label: Text('Alış')),
            DataColumn(label: Text('İade')),
            DataColumn(label: Text('Durum')),
            DataColumn(label: Text('Tutar')),
            DataColumn(label: Text('İşlem')),
          ],
          rows: rentals.map((r) {
            return DataRow(cells: [
              DataCell(Text(r.rentalNumber)),
              DataCell(Text(r.customerName ?? '—')),
              DataCell(Text(r.vehicleLabel)),
              DataCell(Text(_dateFmt.format(r.pickupAt.toLocal()))),
              DataCell(Text(_dateFmt.format(r.returnAt.toLocal()))),
              DataCell(_RentalStatusChip(status: r.status)),
              DataCell(Text(
                r.totalPrice != null ? CurrencyFormatter.format(r.totalPrice!, context) : '—',
              )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (r.status == RentalStatus.confirmed) ...[
                    TextButton(
                      onPressed: () => context.go('/admin/checkin/${r.id}?mode=pickup'),
                      child: const Text('Teslim'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref.read(rentalRepositoryProvider).cancelRental(r.id);
                        ref.invalidate(rentalListProvider);
                      },
                      child: const Text('İptal', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                  if (r.status == RentalStatus.active)
                    TextButton(
                      onPressed: () => context.go('/admin/checkin/${r.id}?mode=return'),
                      child: const Text('İade'),
                    ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _RentalStatusChip extends StatelessWidget {
  const _RentalStatusChip({required this.status});
  final RentalStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RentalStatus.confirmed => AppColors.success,
      RentalStatus.active => const Color(0xFF2563EB),
      RentalStatus.cancelled => AppColors.danger,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
