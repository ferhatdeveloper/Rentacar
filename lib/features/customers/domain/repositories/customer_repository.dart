import '../entities/customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> getCustomers({String? tenantId});
  Future<Customer> createCustomer(CreateCustomerRequest request, {String? tenantId});
}
