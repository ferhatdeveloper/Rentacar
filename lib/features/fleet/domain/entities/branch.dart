import 'package:equatable/equatable.dart';

import '../../../../core/config/app_config.dart';

class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.tenantId,
    required this.name,
    this.city,
    this.phone,
    this.address,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? city;
  final String? phone;
  final String? address;

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        name: json['name'] as String,
        city: json['city'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
      );

  static List<Branch> get demo => [
        Branch(
          id: '10000000-0000-0000-0000-000000000001',
          tenantId: AppConfig.demoTenantId,
          name: 'Merkez Şube',
          city: 'İstanbul',
          phone: '+90 212 555 0100',
        ),
        Branch(
          id: '10000000-0000-0000-0000-000000000002',
          tenantId: AppConfig.demoTenantId,
          name: 'Havalimanı',
          city: 'İstanbul',
          phone: '+90 212 555 0101',
        ),
      ];

  @override
  List<Object?> get props => [id];
}
