import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../rentals/presentation/providers/rental_providers.dart';
import '../../../../shared/widgets/app_kpi_card.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Dashboard yüklenemedi: $e')),
      data: (stats) => _DashboardBody(stats: stats),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final utilization = stats['utilization_rate']?.toString() ?? '0';
    final revenue = stats['monthly_revenue'];
    final revenueLabel = revenue is num
        ? '₺${(revenue / 1000).toStringAsFixed(1)}K'
        : '₺0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Filo ve rezervasyonlarınıza genel bakış',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.6,
                children: [
                  AppKpiCard(
                    title: 'Aktif Kiralama',
                    value: '${stats['active_rentals'] ?? 0}',
                    icon: Icons.key,
                  ),
                  AppKpiCard(
                    title: 'Bugün Teslim',
                    value: '${stats['today_pickups'] ?? 0}',
                    icon: Icons.login,
                  ),
                  AppKpiCard(
                    title: 'Doluluk Oranı',
                    value: '%$utilization',
                    icon: Icons.pie_chart_outline,
                    accentColor: AppColors.success,
                  ),
                  AppKpiCard(
                    title: 'Bu Ay Gelir',
                    value: revenueLabel,
                    icon: Icons.payments_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const _GanttPreview(),
        ],
      ),
    );
  }
}

class _GanttPreview extends StatelessWidget {
  const _GanttPreview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filo Gantt',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...[
              _GanttRow(label: 'Sedan', segments: [
                (0.0, 0.35, AppColors.success),
                (0.35, 0.55, const Color(0xFF2563EB)),
                (0.55, 0.75, const Color(0xFF7C3AED)),
                (0.75, 1.0, AppColors.success),
              ]),
              _GanttRow(label: 'SUV', segments: [
                (0.0, 0.2, AppColors.success),
                (0.2, 0.65, const Color(0xFF2563EB)),
                (0.65, 0.8, AppColors.warning),
                (0.8, 1.0, AppColors.success),
              ]),
              _GanttRow(label: 'Ekonomi', segments: [
                (0.0, 0.45, const Color(0xFF2563EB)),
                (0.45, 0.6, AppColors.success),
                (0.6, 0.9, const Color(0xFF2563EB)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _GanttRow extends StatelessWidget {
  const _GanttRow({required this.label, required this.segments});

  final String label;
  final List<(double start, double end, Color color)> segments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: segments
                        .map(
                          (s) => Positioned(
                            left: constraints.maxWidth * s.$1,
                            width: constraints.maxWidth * (s.$2 - s.$1),
                            top: 4,
                            bottom: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: s.$3,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
