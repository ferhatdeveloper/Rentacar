import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(supabaseClientProvider));
});

final customerListProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  return ref.watch(customerRepositoryProvider).getCustomers();
});
