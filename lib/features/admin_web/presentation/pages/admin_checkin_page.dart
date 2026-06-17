import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../inspections/presentation/providers/inspection_providers.dart';
import '../../../../shared/widgets/app_button.dart';

class AdminCheckInPage extends ConsumerStatefulWidget {
  const AdminCheckInPage({super.key, required this.rentalId, this.mode = 'pickup'});

  final String rentalId;
  final String mode; // pickup | return

  @override
  ConsumerState<AdminCheckInPage> createState() => _AdminCheckInPageState();
}

class _AdminCheckInPageState extends ConsumerState<AdminCheckInPage> {
  final _kmCtrl = TextEditingController(text: '12500');
  final _fuelCtrl = TextEditingController(text: '80');
  final _damageCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _kmCtrl.dispose();
    _fuelCtrl.dispose();
    _damageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final km = int.tryParse(_kmCtrl.text) ?? 0;
    final fuel = int.tryParse(_fuelCtrl.text) ?? 0;
    final damage = double.tryParse(_damageCtrl.text) ?? 0;

    try {
      if (widget.mode == 'pickup') {
        await ref.read(checkInOutProvider.notifier).checkin(
              rentalId: widget.rentalId,
              km: km,
              fuel: fuel,
              notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
            );
      } else {
        await ref.read(checkInOutProvider.notifier).checkout(
              rentalId: widget.rentalId,
              km: km,
              fuel: fuel,
              damageCost: damage,
              notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == 'pickup' ? 'Teslim kaydedildi' : 'İade kaydedildi',
          ),
        ),
      );
      context.go('/admin/rentals');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.mode == 'pickup';
    final loading = ref.watch(checkInOutProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isPickup ? 'Araç Teslim (Check-in)' : 'Araç İade (Check-out)',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Rezervasyon: ${widget.rentalId}'),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _kmCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kilometre',
                      prefixIcon: Icon(Icons.speed),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _fuelCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Yakıt (%)',
                      prefixIcon: Icon(Icons.local_gas_station),
                    ),
                  ),
                  if (!isPickup) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _damageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hasar Tutarı (₺)',
                        prefixIcon: Icon(Icons.car_crash),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notlar',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: isPickup ? 'Teslimi Tamamla' : 'İadeyi Tamamla',
                    expand: true,
                    isLoading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
