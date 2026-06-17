import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../fleet/domain/entities/branch.dart';
import '../../../fleet/domain/entities/vehicle.dart';
import '../../../fleet/presentation/providers/fleet_providers.dart';
import '../../../rentals/domain/entities/rental.dart';
import '../../../rentals/presentation/providers/rental_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_vehicle_card.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  int _step = 0;
  Vehicle? _selectedVehicle;
  Branch? _pickupBranch;
  Branch? _returnBranch;
  DateTime _pickupAt = DateTime.now().add(const Duration(days: 1));
  DateTime _returnAt = DateTime.now().add(const Duration(days: 4));
  RentalPriceQuote? _quote;

  static const _steps = [
    'Tarih & Lokasyon',
    'Araç Seç',
    'Bilgiler',
    'Ödeme',
  ];

  static const _demoCustomerId = '40000000-0000-0000-0000-000000000001';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    final bookingState = ref.watch(bookingNotifierProvider);
    final branchesAsync = ref.watch(branchListProvider);
    final availableAsync = ref.watch(availableVehiclesProvider);

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
              if (bookingState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: MaterialBanner(
                    content: Text(bookingState.error.toString()),
                    backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(bookingNotifierProvider),
                        child: const Text('Kapat'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: isMobile
                    ? _buildStepContent(branchesAsync, availableAsync)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildStepContent(
                              branchesAsync,
                              availableAsync,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: _SummaryPanel(quote: _quote, vehicle: _selectedVehicle)),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: bookingState.isLoading
                          ? null
                          : () => setState(() => _step--),
                      child: const Text('Geri'),
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton(
                    label: _step == _steps.length - 1
                        ? (bookingState.isLoading ? 'İşleniyor...' : 'Rezervasyonu Onayla')
                        : 'Devam',
                    isLoading: bookingState.isLoading,
                    onPressed: bookingState.isLoading || !_canContinue
                        ? null
                        : _onNext,
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
    if (_step == 0) return _pickupBranch != null && _returnBranch != null;
    if (_step == 1) return _selectedVehicle != null;
    return true;
  }

  Future<void> _onNext() async {
    if (_step == 1 && _selectedVehicle != null) {
      final quote = await ref.read(bookingNotifierProvider.notifier).calculatePrice(
            categoryId: _selectedVehicle!.categoryId,
            pickupAt: _pickupAt,
            returnAt: _returnAt,
          );
      setState(() => _quote = quote);
    }

    if (_step == _steps.length - 1) {
      if (_selectedVehicle == null || _pickupBranch == null || _returnBranch == null) {
        return;
      }
      await ref.read(bookingNotifierProvider.notifier).submit(
            CreateRentalRequest(
              customerId: _demoCustomerId,
              vehicleId: _selectedVehicle!.id,
              categoryId: _selectedVehicle!.categoryId,
              pickupBranchId: _pickupBranch!.id,
              returnBranchId: _returnBranch!.id,
              pickupAt: _pickupAt,
              returnAt: _returnAt,
            ),
          );
      if (!mounted) return;
      final result = ref.read(bookingNotifierProvider).value;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rezervasyon oluşturuldu: ${result['rental_number'] ?? 'OK'}',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _step++);
  }

  Widget _buildStepContent(
    AsyncValue<List<Branch>> branchesAsync,
    AsyncValue<List<Vehicle>> availableAsync,
  ) {
    return switch (_step) {
      0 => branchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Şubeler yüklenemedi: $e'),
          data: (branches) => _StepLocation(
            branches: branches,
            pickupBranch: _pickupBranch,
            returnBranch: _returnBranch,
            pickupAt: _pickupAt,
            returnAt: _returnAt,
            onChanged: (pickup, ret, pickupAt, returnAt) => setState(() {
              _pickupBranch = pickup;
              _returnBranch = ret;
              _pickupAt = pickupAt;
              _returnAt = returnAt;
            }),
          ),
        ),
      1 => availableAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Araçlar yüklenemedi: $e'),
          data: (vehicles) => _StepVehicleSelect(
            vehicles: vehicles,
            selected: _selectedVehicle,
            onSelect: (v) => setState(() => _selectedVehicle = v),
          ),
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
  const _StepLocation({
    required this.branches,
    required this.pickupBranch,
    required this.returnBranch,
    required this.pickupAt,
    required this.returnAt,
    required this.onChanged,
  });

  final List<Branch> branches;
  final Branch? pickupBranch;
  final Branch? returnBranch;
  final DateTime pickupAt;
  final DateTime returnAt;
  final void Function(Branch?, Branch?, DateTime, DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: pickupBranch?.id,
              decoration: const InputDecoration(
                labelText: 'Alış Şubesi',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: branches
                  .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                  .toList(),
              onChanged: (id) {
                final branch = branches.firstWhere((b) => b.id == id);
                onChanged(branch, returnBranch, pickupAt, returnAt);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: returnBranch?.id,
              decoration: const InputDecoration(
                labelText: 'İade Şubesi',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: branches
                  .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                  .toList(),
              onChanged: (id) {
                final branch = branches.firstWhere((b) => b.id == id);
                onChanged(pickupBranch, branch, pickupAt, returnAt);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepVehicleSelect extends StatelessWidget {
  const _StepVehicleSelect({
    required this.vehicles,
    required this.selected,
    required this.onSelect,
  });

  final List<Vehicle> vehicles;
  final Vehicle? selected;
  final ValueChanged<Vehicle> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final isSelected = selected?.id == vehicle.id;
        return Stack(
          children: [
            AppVehicleCard(
              vehicle: vehicle,
              compact: true,
              onTap: () => onSelect(vehicle),
            ),
            if (isSelected)
              const Positioned(
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
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
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
  const _SummaryPanel({this.quote, this.vehicle});

  final RentalPriceQuote? quote;
  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
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
              Text(vehicle!.categoryName),
              const Divider(height: AppSpacing.xl),
            ],
            if (quote != null) ...[
              _SummaryRow(
                label: 'Kiralama (${quote!.days} gün)',
                value: '₺${quote!.basePrice.toStringAsFixed(0)}',
              ),
              _SummaryRow(
                label: 'KDV (%20)',
                value: '₺${quote!.taxAmount.toStringAsFixed(0)}',
              ),
              _SummaryRow(
                label: 'Depozito',
                value: '₺${quote!.depositAmount.toStringAsFixed(0)}',
              ),
              const Divider(height: AppSpacing.xl),
              _SummaryRow(
                label: 'Toplam',
                value: '₺${quote!.totalPrice.toStringAsFixed(0)}',
                bold: true,
              ),
            ] else
              Text(
                'Araç seçildikten sonra fiyat hesaplanır.',
                style: Theme.of(context).textTheme.bodySmall,
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
