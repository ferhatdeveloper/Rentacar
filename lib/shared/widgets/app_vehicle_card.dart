import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../features/fleet/domain/entities/vehicle.dart';
import 'app_status_badge.dart';

class AppVehicleCard extends StatelessWidget {
  const AppVehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.compact = false,
    this.showStatus = true,
  });

  final Vehicle vehicle;
  final VoidCallback? onTap;
  final bool compact;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VehicleImage(category: vehicle.category),
            Padding(
              padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.displayName,
                          style: GoogleFonts.outfit(
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (showStatus) AppStatusBadge(status: vehicle.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${vehicle.category} · ${vehicle.transmission} · ${vehicle.fuelType}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: AppPriceTag(price: vehicle.dailyPrice)),
                      if (vehicle.status == VehicleStatus.available)
                        FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          child: const Text('Seç'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.category});

  final String category;

  IconData get _icon => switch (category.toLowerCase()) {
        'suv' => Icons.directions_car_filled,
        'sedan' => Icons.time_to_leave,
        'ekonomi' => Icons.commute,
        'lüks' || 'luks' => Icons.diamond_outlined,
        _ => Icons.directions_car,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            AppColors.navyLight,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Icon(
              _icon,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Center(
            child: Icon(
              _icon,
              size: 64,
              color: AppColors.amber.withValues(alpha: 0.9),
            ),
          ),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
