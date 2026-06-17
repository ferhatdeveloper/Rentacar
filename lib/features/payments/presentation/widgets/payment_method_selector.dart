import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/iraq_payment.dart';
import '../providers/iraq_payment_providers.dart';

class PaymentMethodSelector extends ConsumerWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(selectedPaymentMethodProvider);
    final nebulaStatus = ref.watch(nebulaConnectionProvider);

    final methods = [
      (
        IraqPaymentMethod.fib,
        Icons.account_balance_wallet_outlined,
        l10n.paymentFibDesc,
      ),
      (
        IraqPaymentMethod.fastpay,
        Icons.flash_on_outlined,
        l10n.paymentFastpayDesc,
      ),
      (
        IraqPaymentMethod.switchGateway,
        Icons.swap_horiz,
        l10n.paymentSwitchDesc,
      ),
      (
        IraqPaymentMethod.nebula,
        Icons.point_of_sale,
        l10n.paymentNebulaDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.paymentSelectMethod,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...methods.map((m) {
          final method = m.$1;
          final isSelected = selected == method;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? AppColors.amber.withValues(alpha: 0.12)
                : null,
            child: RadioListTile<IraqPaymentMethod>(
              value: method,
              groupValue: selected,
              onChanged: (v) {
                if (v != null) {
                  ref.read(selectedPaymentMethodProvider.notifier).state = v;
                }
              },
              title: Text(
                method.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.$3),
                  if (method == IraqPaymentMethod.nebula)
                    nebulaStatus.when(
                      loading: () => const Text('Nebula: ...', style: TextStyle(fontSize: 11)),
                      error: (_, __) => Text(
                        'Nebula: bağlantı kontrol edilemedi',
                        style: TextStyle(fontSize: 11, color: AppColors.danger),
                      ),
                      data: (connected) => Text(
                        connected ? 'Nebula: terminal bağlı' : 'Nebula: terminal bağlı değil',
                        style: TextStyle(
                          fontSize: 11,
                          color: connected ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                ],
              ),
              secondary: Icon(m.$2, color: isSelected ? AppColors.amber : null),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          l10n.paymentDepositNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
