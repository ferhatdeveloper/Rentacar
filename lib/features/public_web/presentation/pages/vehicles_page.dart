import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../features/fleet/domain/entities/vehicle.dart';
import '../../../../shared/widgets/app_vehicle_card.dart';

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;
    final crossAxisCount = isMobile ? 1 : (width < 1100 ? 2 : 3);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Araç Filomuz',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${Vehicle.demoVehicles.length} araç listeleniyor',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: isMobile ? 1.1 : 0.75,
                  ),
                  itemCount: Vehicle.demoVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = Vehicle.demoVehicles[index];
                    return AppVehicleCard(
                      vehicle: vehicle,
                      onTap: () => context.go('/rezervasyon'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
