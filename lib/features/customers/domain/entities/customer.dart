import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.tenantId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.identityNumber,
    this.isBlacklisted = false,
    this.loyaltyPoints = 0,
    this.type = 'individual',
  });

  final String id;
  final String tenantId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? identityNumber;
  final bool isBlacklisted;
  final int loyaltyPoints;
  final String type;

  String get fullName => '$firstName $lastName'.trim();

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        identityNumber: json['identity_number'] as String?,
        isBlacklisted: json['is_blacklisted'] as bool? ?? false,
        loyaltyPoints: json['loyalty_points'] as int? ?? 0,
        type: json['type'] as String? ?? 'individual',
      );

  static const demo = Customer(
    id: '40000000-0000-0000-0000-000000000001',
    tenantId: '00000000-0000-0000-0000-000000000001',
    firstName: 'Ahmet',
    lastName: 'Yılmaz',
    email: 'ahmet@example.com',
    phone: '05321234567',
    identityNumber: '12345678901',
  );

  @override
  List<Object?> get props => [id];
}

class CreateCustomerRequest {
  const CreateCustomerRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.identityNumber,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? identityNumber;

  Map<String, dynamic> toRpcParams(String tenantId) => {
        'p_tenant_id': tenantId,
        'p_first_name': firstName,
        'p_last_name': lastName,
        'p_email': email,
        'p_phone': phone,
        'p_identity_number': identityNumber,
      };
}
