import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../payments/domain/entities/iraq_payment.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../payments/presentation/providers/iraq_payment_providers.dart';
import '../../../payments/presentation/widgets/payment_method_selector.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
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
  String? _customerId;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  bool _paymentProcessing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = l10n.bookingSteps;
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    final bookingState = ref.watch(bookingNotifierProvider);
    final branchesAsync = ref.watch(branchListProvider);
    final availableAsync = ref.watch(availableVehiclesProvider);
    final isLoading = bookingState.isLoading || _paymentProcessing;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bookingTitle,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _StepIndicator(steps: steps, currentStep: _step),
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
                      onPressed: isLoading ? null : () => setState(() => _step--),
                      child: Text(l10n.btnBack),
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton(
                    label: _step == steps.length - 1
                        ? (isLoading ? l10n.btnProcessing : l10n.btnConfirmBooking)
                        : l10n.btnContinue,
                    isLoading: isLoading,
                    onPressed: isLoading || !_canContinue(steps.length) ? null : _onNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canContinue(int stepCount) {
    if (_step == 0) return _pickupBranch != null && _returnBranch != null;
    if (_step == 1) return _selectedVehicle != null;
    if (_step == 2) {
      return _nameCtrl.text.trim().isNotEmpty &&
          _emailCtrl.text.trim().isNotEmpty &&
          _phoneCtrl.text.trim().isNotEmpty;
    }
    if (_step == stepCount - 1) {
      return true;
    }
    return true;
  }

  (String, String) _splitName() {
    final parts = _nameCtrl.text.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  Future<void> _onNext() async {
    final l10n = AppLocalizations.of(context);
    final lastStep = l10n.bookingSteps.length - 1;

    if (_step == 1 && _selectedVehicle != null) {
      final quote = await ref.read(bookingNotifierProvider.notifier).calculatePrice(
            categoryId: _selectedVehicle!.categoryId,
            pickupAt: _pickupAt,
            returnAt: _returnAt,
          );
      setState(() => _quote = quote);
    }

    if (_step == 2) {
      final (firstName, lastName) = _splitName();
      final customer = await ref.read(customerRepositoryProvider).createCustomer(
            CreateCustomerRequest(
              firstName: firstName,
              lastName: lastName.isEmpty ? '-' : lastName,
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              identityNumber: _licenseCtrl.text.trim().isEmpty
                  ? null
                  : _licenseCtrl.text.trim(),
            ),
          );
      _customerId = customer.id;
    }

    if (_step == lastStep) {
      if (_selectedVehicle == null ||
          _pickupBranch == null ||
          _returnBranch == null ||
          _customerId == null ||
          _quote == null) {
        return;
      }

      final paymentMethod = ref.read(selectedPaymentMethodProvider);
      setState(() => _paymentProcessing = true);
      final paymentResult = await ref.read(paymentProcessorProvider).process(
            PaymentRequest(
              method: paymentMethod,
              amount: _quote!.totalPrice,
              currencyCode: AppConfig.currencyCode,
              referenceId: _customerId!,
              description: 'Rental booking',
              customerPhone: _phoneCtrl.text.trim(),
              customerEmail: _emailCtrl.text.trim(),
            ),
          );
      if (!mounted) return;
      setState(() => _paymentProcessing = false);

      if (!paymentResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(paymentResult.message ?? 'Payment failed')),
        );
        return;
      }

      await ref.read(bookingNotifierProvider.notifier).submit(
            CreateRentalRequest(
              customerId: _customerId!,
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
        final rentalId = result['id']?.toString();
        if (rentalId != null && _quote != null) {
          final payRepo = ref.read(paymentRepositoryProvider);
          await payRepo.recordPayment(
            rentalId: rentalId,
            customerId: _customerId!,
            type: 'rental',
            amount: _quote!.totalPrice,
            method: paymentMethod.code,
            provider: paymentMethod.displayName,
            providerTransactionId: paymentResult.transactionId,
          );
          await payRepo.createInvoice(
            rentalId: rentalId,
            customerId: _customerId!,
            subtotal: _quote!.basePrice,
            taxAmount: _quote!.taxAmount,
          );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.bookingSuccess}: ${result['rental_number'] ?? 'OK'}',
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
      2 => _StepDriverInfo(
            nameController: _nameCtrl,
            emailController: _emailCtrl,
            phoneController: _phoneCtrl,
            licenseController: _licenseCtrl,
            onChanged: () => setState(() {}),
          ),
      3 => const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: PaymentMethodSelector(),
            ),
          ),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: pickupBranch?.id,
              decoration: InputDecoration(
                labelText: l10n.formPickupBranch,
                prefixIcon: const Icon(Icons.location_on_outlined),
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
              decoration: InputDecoration(
                labelText: l10n.formReturnBranch,
                prefixIcon: const Icon(Icons.location_on_outlined),
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
  const _StepDriverInfo({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.licenseController,
    required this.onChanged,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController licenseController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(labelText: l10n.formFullName),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(labelText: l10n.formEmail),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(labelText: l10n.formPhone),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: licenseController,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(labelText: l10n.formLicense),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summaryTitle,
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
                label: l10n.summaryRentalDays(quote!.days),
                value: CurrencyFormatter.format(quote!.basePrice, context),
              ),
              _SummaryRow(
                label: l10n.summaryTax,
                value: CurrencyFormatter.format(quote!.taxAmount, context),
              ),
              _SummaryRow(
                label: l10n.summaryDeposit,
                value: CurrencyFormatter.format(quote!.depositAmount, context),
              ),
              const Divider(height: AppSpacing.xl),
              _SummaryRow(
                label: l10n.summaryTotal,
                value: CurrencyFormatter.format(quote!.totalPrice, context),
                bold: true,
              ),
            ] else
              Text(
                l10n.summaryPricePending,
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
