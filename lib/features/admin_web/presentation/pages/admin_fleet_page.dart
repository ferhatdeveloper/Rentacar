import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../fleet/domain/entities/vehicle.dart';
import '../../../fleet/presentation/providers/fleet_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_vehicle_card.dart';

class AdminFleetPage extends ConsumerWidget {
  const AdminFleetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filo Yönetimi',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tüm araçlarınızı görüntüleyin ve durumlarını takip edin',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(
                title: 'Araçlar yüklenemedi',
                message: e.toString(),
                onRetry: () => ref.invalidate(vehicleListProvider),
              ),
              data: (vehicles) => _FleetGrid(vehicles: vehicles),
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetGrid extends StatelessWidget {
  const _FleetGrid({required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 1200 ? 3 : (width > 800 ? 2 : 1);

    if (vehicles.isEmpty) {
      return const AppEmptyState(
        title: 'Henüz araç yok',
        message: 'Filonuza ilk aracınızı ekleyin.',
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: crossAxisCount == 1 ? 1.2 : 0.85,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        return AppVehicleCard(
          vehicle: vehicles[index],
          showStatus: true,
        );
      },
    );
  }
}
