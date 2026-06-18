import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../fleet/domain/entities/vehicle.dart';
import '../../../fleet/presentation/providers/fleet_providers.dart';
import '../../../rentals/presentation/providers/rental_providers.dart';
import '../../../../shared/widgets/app_kpi_card.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final vehiclesAsync = ref.watch(vehicleListProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Dashboard yüklenemedi: $e')),
      data: (stats) => _DashboardBody(
        stats: stats,
        vehicles: vehiclesAsync.valueOrNull ?? const [],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats, required this.vehicles});

  final Map<String, dynamic> stats;
  final List<Vehicle> vehicles;

  int _count(bool Function(Vehicle) test) => vehicles.where(test).length;

  @override
  Widget build(BuildContext context) {
    final utilization = stats['utilization_rate']?.toString() ?? '0';
    final revenue = stats['monthly_revenue'];
    final revenueLabel =
        revenue is num ? '₺${(revenue / 1000).toStringAsFixed(1)}K' : '₺0';

    final totalVehicles = vehicles.isNotEmpty
        ? vehicles.length
        : (stats['total_vehicles'] as num?)?.toInt() ?? 0;
    final availableVehicles = vehicles.isNotEmpty
        ? _count((v) => v.status == VehicleStatus.available)
        : (stats['available_vehicles'] as num?)?.toInt() ?? 0;
    final rentedVehicles = _count((v) => v.status == VehicleStatus.rented);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Filo ve rezervasyonlarınıza genel bakış',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 700
                      ? 3
                      : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.6,
                children: [
                  AppKpiCard(
                    title: 'Günlük Çıkış',
                    value: '${stats['today_pickups'] ?? 0}',
                    icon: Icons.login,
                  ),
                  AppKpiCard(
                    title: 'Günlük Dönüş',
                    value: '${stats['today_returns'] ?? 0}',
                    icon: Icons.logout,
                    accentColor: AppColors.success,
                  ),
                  AppKpiCard(
                    title: 'Aktif Kiralama',
                    value: '${stats['active_rentals'] ?? 0}',
                    icon: Icons.key,
                  ),
                  AppKpiCard(
                    title: 'Günlük Ciro',
                    value: revenueLabel,
                    icon: Icons.payments_outlined,
                  ),
                  AppKpiCard(
                    title: 'Doluluk Oranı',
                    value: '%$utilization',
                    icon: Icons.pie_chart_outline,
                    accentColor: AppColors.success,
                  ),
                  AppKpiCard(
                    title: 'Toplam Araç',
                    value: '$totalVehicles',
                    icon: Icons.directions_car_filled,
                  ),
                  AppKpiCard(
                    title: 'Kirada',
                    value: '$rentedVehicles',
                    icon: Icons.car_rental,
                    accentColor: const Color(0xFF2563EB),
                  ),
                  AppKpiCard(
                    title: 'Müsait Araç',
                    value: '$availableVehicles',
                    icon: Icons.check_circle_outline,
                    accentColor: AppColors.success,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _VehicleStatusTable(vehicles: vehicles),
          const SizedBox(height: AppSpacing.xl),
          const _GanttPreview(),
        ],
      ),
    );
  }
}

/// Beto Yazılım referansındaki "Araç Durumu" tablosunun karşılığı —
/// araçları sınıfa (kategori) göre gruplar ve duruma göre sayar.
class _VehicleStatusTable extends StatelessWidget {
  const _VehicleStatusTable({required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    final classes = <String>{for (final v in vehicles) v.categoryName}.toList()
      ..sort();

    int countFor(String cls, VehicleStatus? status) => vehicles
        .where((v) => v.categoryName == cls && (status == null || v.status == status))
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: AppColors.amber, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Araç Durumu',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (classes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text('Araç verisi bulunamadı'),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  columns: const [
                    DataColumn(label: Text('Sınıf')),
                    DataColumn(label: Text('Mevcut'), numeric: true),
                    DataColumn(label: Text('Müsait'), numeric: true),
                    DataColumn(label: Text('Kirada'), numeric: true),
                    DataColumn(label: Text('Bakım'), numeric: true),
                    DataColumn(label: Text('Son Durum')),
                  ],
                  rows: [
                    for (final cls in classes)
                      DataRow(cells: [
                        DataCell(Text(cls, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text('${countFor(cls, null)}')),
                        DataCell(_CountChip(
                          count: countFor(cls, VehicleStatus.available),
                          color: AppColors.success,
                        )),
                        DataCell(_CountChip(
                          count: countFor(cls, VehicleStatus.rented),
                          color: const Color(0xFF2563EB),
                        )),
                        DataCell(_CountChip(
                          count: countFor(cls, VehicleStatus.maintenance),
                          color: AppColors.warning,
                        )),
                        DataCell(Text(
                          countFor(cls, VehicleStatus.available) > 0 ? 'Müsait' : 'Dolu',
                          style: TextStyle(
                            color: countFor(cls, VehicleStatus.available) > 0
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final muted = count == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: (muted ? AppColors.textSecondary : color).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: muted ? AppColors.textSecondary : color,
          fontWeight: FontWeight.w700,
        ),
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
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
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
