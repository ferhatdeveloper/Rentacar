import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../fleet/presentation/providers/fleet_providers.dart';
import '../providers/admin_extra_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class AdminMaintenancePage extends ConsumerWidget {
  const AdminMaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(maintenanceListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bakım', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700)),
              FilledButton.icon(
                onPressed: () => _showAdd(context, ref),
                icon: const Icon(Icons.build_outlined),
                label: const Text('Bakım Planla'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(title: 'Yüklenemedi', message: '$e'),
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final m = items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.car_repair),
                      title: Text('${m['brand']} ${m['model']} · ${m['plate_number']}'),
                      subtitle: Text('${m['type']} — ${m['description'] ?? ''}'),
                      trailing: Chip(label: Text('${m['status']}')),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    final vehicles = await ref.read(vehicleListProvider.future);
    if (vehicles.isEmpty || !context.mounted) return;
    final descCtrl = TextEditingController();
    var vehicleId = vehicles.first.id;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bakım Planla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: vehicleId,
              items: vehicles
                  .map((v) => DropdownMenuItem(value: v.id, child: Text(v.displayName)))
                  .toList(),
              onChanged: (v) => vehicleId = v ?? vehicleId,
              decoration: const InputDecoration(labelText: 'Araç'),
            ),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Açıklama')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              await createMaintenanceRecord(
                ref: ref,
                vehicleId: vehicleId,
                description: descCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
