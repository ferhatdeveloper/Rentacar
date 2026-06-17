import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../shared/widgets/app_kpi_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  AppKpiCard(
                    title: 'Aktif Kiralama',
                    value: '12',
                    icon: Icons.key,
                    trend: '+2',
                  ),
                  AppKpiCard(
                    title: 'Bugün Teslim',
                    value: '5',
                    icon: Icons.login,
                  ),
                  AppKpiCard(
                    title: 'Doluluk Oranı',
                    value: '%78',
                    icon: Icons.pie_chart_outline,
                    trend: '+5%',
                    accentColor: AppColors.success,
                  ),
                  AppKpiCard(
                    title: 'Bu Ay Gelir',
                    value: '₺124.5K',
                    icon: Icons.payments_outlined,
                    trend: '+12%',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const _GanttPreview(),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _UpcomingList(title: 'Yaklaşan Teslimler', items: const [
                '14:00 — BMW 320i (34 ABC 123)',
                '16:30 — Mercedes GLC (34 DEF 456)',
                '18:00 — Audi A6 (34 JKL 012)',
              ])),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _UpcomingList(title: 'Geciken İade', warning: true, items: const [
                '09:00 — Renault Clio (34 GHI 789)',
              ])),
            ],
          ),
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
            ...const [
              _GanttRow(label: 'Sedan', segments: [
                (0.0, 0.35, AppColors.success),
                (0.35, 0.55, Color(0xFF2563EB)),
                (0.55, 0.75, Color(0xFF7C3AED)),
                (0.75, 1.0, AppColors.success),
              ]),
              _GanttRow(label: 'SUV', segments: [
                (0.0, 0.2, AppColors.success),
                (0.2, 0.65, Color(0xFF2563EB)),
                (0.65, 0.8, AppColors.warning),
                (0.8, 1.0, AppColors.success),
              ]),
              _GanttRow(label: 'Ekonomi', segments: [
                (0.0, 0.45, Color(0xFF2563EB)),
                (0.45, 0.6, AppColors.success),
                (0.6, 0.9, Color(0xFF2563EB)),
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

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({
    required this.title,
    required this.items,
    this.warning = false,
  });

  final String title;
  final List<String> items;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (warning)
                  const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                if (warning) const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
