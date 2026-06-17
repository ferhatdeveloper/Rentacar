import 'package:equatable/equatable.dart';

enum UserRole {
  superAdmin('super_admin', 'Süper Admin'),
  tenantOwner('tenant_owner', 'Firma Sahibi'),
  branchManager('branch_manager', 'Şube Müdürü'),
  staff('staff', 'Personel');

  const UserRole(this.value, this.label);
  final String value;
  final String label;

  static UserRole fromValue(String v) => UserRole.values.firstWhere(
        (r) => r.value == v,
        orElse: () => UserRole.staff,
      );
}

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String tenantId;
  final String email;
  final String fullName;
  final UserRole role;

  static const demo = AuthUser(
    id: '50000000-0000-0000-0000-000000000001',
    tenantId: '00000000-0000-0000-0000-000000000001',
    email: 'admin@premium-rent.com',
    fullName: 'Admin Kullanıcı',
    role: UserRole.tenantOwner,
  );

  @override
  List<Object?> get props => [id];
}
