import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../features/fleet/domain/entities/vehicle.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_vehicle_card.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _step = 0;
  Vehicle? _selectedVehicle;

  static const _steps = [
    'Tarih & Lokasyon',
    'Araç Seç',
    'Bilgiler',
    'Ödeme',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rezervasyon',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _StepIndicator(steps: _steps, currentStep: _step),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: isMobile
                    ? _buildStepContent()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildStepContent()),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: _SummaryPanel(vehicle: _selectedVehicle)),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Geri'),
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton(
                    label: _step == _steps.length - 1 ? 'Ödemeyi Tamamla' : 'Devam',
                    onPressed: _canContinue
                        ? () {
                            if (_step < _steps.length - 1) {
                              setState(() => _step++);
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canContinue {
    if (_step == 1) return _selectedVehicle != null;
    return true;
  }

  Widget _buildStepContent() {
    return switch (_step) {
      0 => const _StepLocation(),
      1 => _StepVehicleSelect(
          selected: _selectedVehicle,
          onSelect: (v) => setState(() => _selectedVehicle = v),
        ),
      2 => const _StepDriverInfo(),
      3 => const _StepPayment(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.currentStep});

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < currentStep
                  ? AppColors.amber
                  : Colors.black.withValues(alpha: 0.08),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex <= currentStep;
        return Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isActive ? AppColors.amber : Colors.grey.shade200,
              child: Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  color: isActive ? AppColors.navy : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StepLocation extends StatelessWidget {
  const _StepLocation();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Alış Şubesi',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'merkez', child: Text('Merkez Şube')),
                DropdownMenuItem(value: 'havalimani', child: Text('Havalimanı')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'İade Şubesi',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'merkez', child: Text('Merkez Şube')),
                DropdownMenuItem(value: 'havalimani', child: Text('Havalimanı')),
              ],
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StepVehicleSelect extends StatelessWidget {
  const _StepVehicleSelect({required this.selected, required this.onSelect});

  final Vehicle? selected;
  final ValueChanged<Vehicle> onSelect;

  @override
  Widget build(BuildContext context) {
    final available =
        Vehicle.demoVehicles.where((v) => v.status == VehicleStatus.available);

    return ListView.separated(
      itemCount: available.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final vehicle = available.elementAt(index);
        final isSelected = selected?.id == vehicle.id;
        return Stack(
          children: [
            AppVehicleCard(
              vehicle: vehicle,
              compact: true,
              onTap: () => onSelect(vehicle),
            ),
            if (isSelected)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: CircleAvatar(
                  backgroundColor: AppColors.amber,
                  radius: 14,
                  child: Icon(Icons.check, size: 18, color: AppColors.navy),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StepDriverInfo extends StatelessWidget {
  const _StepDriverInfo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: 'Ad Soyad')),
            SizedBox(height: AppSpacing.md),
            TextField(decoration: InputDecoration(labelText: 'E-posta')),
            SizedBox(height: AppSpacing.md),
            TextField(decoration: InputDecoration(labelText: 'Telefon')),
            SizedBox(height: AppSpacing.md),
            TextField(decoration: InputDecoration(labelText: 'Ehliyet No')),
          ],
        ),
      ),
    );
  }
}

class _StepPayment extends StatelessWidget {
  const _StepPayment();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ödeme yöntemi seçin'),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Kredi / Banka Kartı'),
              trailing: Icon(Icons.check_circle, color: AppColors.amber),
            ),
            const Divider(),
            Text(
              'Depozito tutarı kiralama bitiminde iade edilir.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({this.vehicle});

  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final days = 3;
    final daily = vehicle?.dailyPrice ?? 0;
    final subtotal = daily * days;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rezervasyon Özeti',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (vehicle != null) ...[
              Text(vehicle!.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(vehicle!.category),
              const Divider(height: AppSpacing.xl),
            ],
            _SummaryRow(label: 'Kiralama ($days gün)', value: '₺${subtotal.toStringAsFixed(0)}'),
            _SummaryRow(label: 'KDV (%20)', value: '₺${(subtotal * 0.2).toStringAsFixed(0)}'),
            const Divider(height: AppSpacing.xl),
            _SummaryRow(
              label: 'Toplam',
              value: '₺${(subtotal * 1.2).toStringAsFixed(0)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null)),
        ],
      ),
    );
  }
}
