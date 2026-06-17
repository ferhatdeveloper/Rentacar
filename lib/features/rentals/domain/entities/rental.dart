import 'package:equatable/equatable.dart';

enum RentalStatus {
  draft,
  pending,
  confirmed,
  active,
  returned,
  closed,
  cancelled,
  noShow;

  String get label => switch (this) {
        RentalStatus.draft => 'Taslak',
        RentalStatus.pending => 'Beklemede',
        RentalStatus.confirmed => 'Onaylandı',
        RentalStatus.active => 'Aktif',
        RentalStatus.returned => 'İade Edildi',
        RentalStatus.closed => 'Kapalı',
        RentalStatus.cancelled => 'İptal',
        RentalStatus.noShow => 'Gelmedi',
      };

  static RentalStatus fromDb(String value) => switch (value) {
        'pending' => RentalStatus.pending,
        'confirmed' => RentalStatus.confirmed,
        'active' => RentalStatus.active,
        'returned' => RentalStatus.returned,
        'closed' => RentalStatus.closed,
        'cancelled' => RentalStatus.cancelled,
        'no_show' => RentalStatus.noShow,
        _ => RentalStatus.draft,
      };
}

class Rental extends Equatable {
  const Rental({
    required this.id,
    required this.tenantId,
    required this.rentalNumber,
    required this.pickupAt,
    required this.returnAt,
    required this.status,
    this.customerId,
    this.customerName,
    this.vehicleId,
    this.plateNumber,
    this.brand,
    this.model,
    this.totalPrice,
    this.depositAmount,
    this.channel = 'web',
  });

  final String id;
  final String tenantId;
  final String rentalNumber;
  final DateTime pickupAt;
  final DateTime returnAt;
  final RentalStatus status;
  final String? customerId;
  final String? customerName;
  final String? vehicleId;
  final String? plateNumber;
  final String? brand;
  final String? model;
  final double? totalPrice;
  final double? depositAmount;
  final String channel;

  String get vehicleLabel {
    if (brand != null && model != null) return '$brand $model';
    return plateNumber ?? '—';
  }

  factory Rental.fromJson(Map<String, dynamic> json) => Rental(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        rentalNumber: json['rental_number'] as String,
        pickupAt: DateTime.parse(json['pickup_at'] as String),
        returnAt: DateTime.parse(json['return_at'] as String),
        status: RentalStatus.fromDb(json['status'] as String? ?? 'draft'),
        customerId: json['customer_id'] as String?,
        customerName: json['customer_name'] as String?,
        vehicleId: json['vehicle_id'] as String?,
        plateNumber: json['plate_number'] as String?,
        brand: json['brand'] as String?,
        model: json['model'] as String?,
        totalPrice: _toDouble(json['total_price']),
        depositAmount: _toDouble(json['deposit_amount']),
        channel: json['channel'] as String? ?? 'web',
      );

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [id];
}

class RentalPriceQuote extends Equatable {
  const RentalPriceQuote({
    required this.days,
    required this.dailyPrice,
    required this.basePrice,
    required this.taxAmount,
    required this.totalPrice,
    required this.depositAmount,
    this.currency = 'TRY',
  });

  final int days;
  final double dailyPrice;
  final double basePrice;
  final double taxAmount;
  final double totalPrice;
  final double depositAmount;
  final String currency;

  factory RentalPriceQuote.fromJson(Map<String, dynamic> json) =>
      RentalPriceQuote(
        days: json['days'] as int? ?? 1,
        dailyPrice: VehiclePriceHelper.toDouble(json['daily_price']),
        basePrice: VehiclePriceHelper.toDouble(json['base_price']),
        taxAmount: VehiclePriceHelper.toDouble(json['tax_amount']),
        totalPrice: VehiclePriceHelper.toDouble(json['total_price']),
        depositAmount: VehiclePriceHelper.toDouble(json['deposit_amount']),
        currency: json['currency'] as String? ?? 'TRY',
      );

  @override
  List<Object?> get props => [totalPrice];
}

abstract final class VehiclePriceHelper {
  static double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class CreateRentalRequest extends Equatable {
  const CreateRentalRequest({
    required this.customerId,
    required this.vehicleId,
    required this.categoryId,
    required this.pickupBranchId,
    required this.returnBranchId,
    required this.pickupAt,
    required this.returnAt,
    this.channel = 'web',
  });

  final String customerId;
  final String vehicleId;
  final String categoryId;
  final String pickupBranchId;
  final String returnBranchId;
  final DateTime pickupAt;
  final DateTime returnAt;
  final String channel;

  Map<String, dynamic> toRpcParams(String tenantId) => {
        'p_tenant_id': tenantId,
        'p_customer_id': customerId,
        'p_vehicle_id': vehicleId,
        'p_category_id': categoryId,
        'p_pickup_branch_id': pickupBranchId,
        'p_return_branch_id': returnBranchId,
        'p_pickup_at': pickupAt.toUtc().toIso8601String(),
        'p_return_at': returnAt.toUtc().toIso8601String(),
        'p_channel': channel,
      };

  @override
  List<Object?> get props => [vehicleId, pickupAt, returnAt];
}
