import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../features/fleet/domain/entities/vehicle.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.status});

  final VehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final color = Color(status.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class AppPriceTag extends StatelessWidget {
  const AppPriceTag({
    super.key,
    required this.price,
    this.suffix = '/gün',
    this.large = false,
  });

  final double price;
  final String suffix;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
        children: [
          TextSpan(
            text: '₺${price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                  fontSize: large ? 28 : 20,
                ),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}
