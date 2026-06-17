import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class AdminPaymentsPage extends ConsumerWidget {
  const AdminPaymentsPage({super.key});

  static final _dateFmt = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ödemeler',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: paymentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(
                title: 'Yüklenemedi',
                onRetry: () => ref.invalidate(paymentListProvider),
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return const AppEmptyState(title: 'Ödeme kaydı yok');
                }
                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Tarih')),
                        DataColumn(label: Text('Müşteri')),
                        DataColumn(label: Text('Rezervasyon')),
                        DataColumn(label: Text('Tür')),
                        DataColumn(label: Text('Tutar')),
                        DataColumn(label: Text('Durum')),
                      ],
                      rows: payments.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(
                            p.paidAt != null ? _dateFmt.format(p.paidAt!.toLocal()) : '—',
                          )),
                          DataCell(Text(p.customerName ?? '—')),
                          DataCell(Text(p.rentalNumber ?? '—')),
                          DataCell(Text(p.typeLabel)),
                          DataCell(Text('₺${p.amount.toStringAsFixed(0)}')),
                          DataCell(_StatusChip(status: p.status)),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PaymentStatus.completed => AppColors.success,
      PaymentStatus.failed => AppColors.danger,
      PaymentStatus.refunded => AppColors.warning,
      _ => AppColors.textSecondary,
    };
    return Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.w600));
  }
}
