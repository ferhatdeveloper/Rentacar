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
    this.country,
    this.address,
    this.createdAt,
    this.debtTotal = 0,
    this.creditTotal = 0,
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
  final String? country;
  final String? address;
  final DateTime? createdAt;
  final double debtTotal;
  final double creditTotal;

  String get fullName => '$firstName $lastName'.trim();

  bool get isCorporate => type == 'corporate';

  /// Bakiye = Borç Toplam − Alacak Toplam (Beto referansındaki gibi).
  double get balance => debtTotal - creditTotal;

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
        country: json['country'] as String?,
        address: json['address'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        debtTotal: (json['debt_total'] as num?)?.toDouble() ?? 0,
        creditTotal: (json['credit_total'] as num?)?.toDouble() ?? 0,
      );

  static final demo = Customer(
    id: '40000000-0000-0000-0000-000000000001',
    tenantId: '00000000-0000-0000-0000-000000000001',
    firstName: 'Ahmet',
    lastName: 'Yılmaz',
    email: 'ahmet@example.com',
    phone: '05321234567',
    identityNumber: '12345678901',
    country: 'TÜRKİYE',
    address: 'Erbil Quartz Hotel',
    createdAt: DateTime(2026, 1, 25),
    debtTotal: 266.68,
    creditTotal: 400.02,
    loyaltyPoints: 120,
  );

  /// Demo modunda müşteri listesini doldurmak için örnek kayıtlar.
  static final demoList = <Customer>[
    demo,
    Customer(
      id: '40000000-0000-0000-0000-000000000002',
      tenantId: '00000000-0000-0000-0000-000000000001',
      firstName: 'Rana',
      lastName: 'Hajiyava',
      email: 'rana.h@hotmail.com',
      phone: '+9647504762246',
      country: 'IRAK',
      address: 'Quartz Hotel Erbil',
      createdAt: DateTime(2026, 1, 13),
      debtTotal: 530.04,
      creditTotal: 530.04,
      loyaltyPoints: 40,
    ),
    Customer(
      id: '40000000-0000-0000-0000-000000000003',
      tenantId: '00000000-0000-0000-0000-000000000001',
      firstName: 'Zawita',
      lastName: 'Duhok',
      email: 'azawity@yahoo.com',
      phone: '+31617503887',
      country: 'IRAK',
      address: 'Zawita Duhok',
      createdAt: DateTime(2026, 1, 2),
      debtTotal: 900.40,
      creditTotal: 0,
      loyaltyPoints: 0,
    ),
    Customer(
      id: '40000000-0000-0000-0000-000000000004',
      tenantId: '00000000-0000-0000-0000-000000000001',
      firstName: 'Mohammed',
      lastName: 'Abed',
      email: 'abed.sa@bobbio.se',
      phone: '+46721414433',
      type: 'corporate',
      country: 'GERMANY',
      address: 'Erbil Hotel Hemra',
      createdAt: DateTime(2026, 7, 8),
      debtTotal: 980.14,
      creditTotal: 665.00,
      loyaltyPoints: 260,
    ),
    Customer(
      id: '40000000-0000-0000-0000-000000000005',
      tenantId: '00000000-0000-0000-0000-000000000001',
      firstName: 'Abeer',
      lastName: 'Alabed',
      email: 'aalabed@hotmail.com',
      phone: '+9647722444407',
      country: 'SURİYE',
      address: 'MRF Quartz D12-9',
      createdAt: DateTime(2026, 6, 18),
      debtTotal: 800.10,
      creditTotal: 800.10,
      loyaltyPoints: 15,
    ),
    Customer(
      id: '40000000-0000-0000-0000-000000000006',
      tenantId: '00000000-0000-0000-0000-000000000001',
      firstName: 'Adham',
      lastName: 'Majed',
      email: 'adham.m@hotmail.com',
      phone: '+9647517711469',
      country: 'IRAK',
      address: 'Bakhtiyari Next To Shahid Kochar',
      createdAt: DateTime(2026, 7, 23),
      debtTotal: 2236.00,
      creditTotal: 2236.00,
      loyaltyPoints: 90,
    ),
    Customer(
      id: '40000000-0000-0000-0000-000000000007',
      tenantId: '00000000-0000-0000-0000-000000000001',
      firstName: 'Sabri',
      lastName: 'ISA',
      email: 'sabri.isa@bobbio.se',
      phone: '+46722141433',
      country: 'IRAK',
      address: 'Mhalat Shahidan Hmara 3',
      createdAt: DateTime(2026, 7, 6),
      debtTotal: 980.14,
      creditTotal: 980.14,
      isBlacklisted: true,
      loyaltyPoints: 0,
    ),
  ];

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
