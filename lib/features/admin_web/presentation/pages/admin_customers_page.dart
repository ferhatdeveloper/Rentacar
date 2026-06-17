import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class AdminCustomersPage extends ConsumerWidget {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Müşteriler',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              FilledButton.icon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Yeni Müşteri'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(
                title: 'Yüklenemedi',
                message: e.toString(),
                onRetry: () => ref.invalidate(customerListProvider),
              ),
              data: (customers) {
                if (customers.isEmpty) {
                  return const AppEmptyState(title: 'Müşteri bulunamadı');
                }
                return Card(
                  child: ListView.separated(
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = customers[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.amber.withValues(alpha: 0.2),
                          child: Text(c.firstName.isNotEmpty ? c.firstName[0] : '?'),
                        ),
                        title: Text(c.fullName),
                        subtitle: Text('${c.phone ?? ''} · ${c.email ?? ''}'),
                        trailing: c.isBlacklisted
                            ? const Chip(
                                label: Text('Kara Liste', style: TextStyle(fontSize: 11)),
                              )
                            : Text('${c.loyaltyPoints} puan'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final firstName = TextEditingController();
    final lastName = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Müşteri'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstName, decoration: const InputDecoration(labelText: 'Ad')),
              TextField(controller: lastName, decoration: const InputDecoration(labelText: 'Soyad')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'E-posta')),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telefon')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              await ref.read(customerRepositoryProvider).createCustomer(
                    CreateCustomerRequest(
                      firstName: firstName.text,
                      lastName: lastName.text,
                      email: email.text,
                      phone: phone.text,
                    ),
                  );
              ref.invalidate(customerListProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
