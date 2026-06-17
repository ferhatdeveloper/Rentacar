import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../rentals/presentation/providers/rental_providers.dart';
import '../../../../shared/widgets/app_kpi_card.dart';

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(revenueReportProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raporlar',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xl),
          revenueAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Hata: $e'),
            data: (rev) => GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.6,
              children: [
                AppKpiCard(
                  title: '30 Gün Gelir',
                  value: '₺${(rev['total_revenue'] as num?)?.toStringAsFixed(0) ?? '0'}',
                  icon: Icons.payments_outlined,
                ),
                AppKpiCard(
                  title: 'Rezervasyon Sayısı',
                  value: '${rev['rental_count'] ?? 0}',
                  icon: Icons.calendar_month,
                ),
                AppKpiCard(
                  title: 'Ort. Kiralama Tutarı',
                  value: '₺${(rev['avg_daily_rate'] as num?)?.toStringAsFixed(0) ?? '0'}',
                  icon: Icons.trending_up,
                ),
                statsAsync.when(
                  loading: () => const AppKpiCard(
                    title: 'Doluluk',
                    value: '—',
                    icon: Icons.pie_chart,
                  ),
                  error: (_, __) => const AppKpiCard(
                    title: 'Doluluk',
                    value: '—',
                    icon: Icons.pie_chart,
                  ),
                  data: (s) => AppKpiCard(
                    title: 'Doluluk Oranı',
                    value: '%${s['utilization_rate'] ?? 0}',
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Özet',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Detaylı raporlar (araç karlılığı, kanal performansı, müşteri LTV) '
                    'bir sonraki sürümde eklenecektir. Mevcut veriler PostgREST RPC '
                    'üzerinden canlı olarak çekilmektedir.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
