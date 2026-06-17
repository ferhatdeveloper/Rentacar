import 'package:equatable/equatable.dart';

enum VehicleStatus {
  available('Müsait', 0xFF0D9488),
  rented('Kirada', 0xFF2563EB),
  maintenance('Bakımda', 0xFFD97706),
  reserved('Rezerve', 0xFF7C3AED),
  outOfService('Servis Dışı', 0xFF6B7280);

  const VehicleStatus(this.label, this.colorValue);
  final String label;
  final int colorValue;

  static VehicleStatus fromDb(String value) => switch (value) {
        'available' => VehicleStatus.available,
        'rented' => VehicleStatus.rented,
        'maintenance' => VehicleStatus.maintenance,
        'reserved' => VehicleStatus.reserved,
        _ => VehicleStatus.outOfService,
      };

  String get dbValue => switch (this) {
        VehicleStatus.available => 'available',
        VehicleStatus.rented => 'rented',
        VehicleStatus.maintenance => 'maintenance',
        VehicleStatus.reserved => 'reserved',
        VehicleStatus.outOfService => 'out_of_service',
      };
}

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.tenantId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.categoryId,
    required this.categoryName,
    required this.dailyPrice,
    required this.status,
    this.branchId,
    this.branchName,
    this.year,
    this.fuelType = 'petrol',
    this.transmission = 'automatic',
    this.currentKm = 0,
    this.depositAmount = 0,
    this.features = const [],
  });

  final String id;
  final String tenantId;
  final String plateNumber;
  final String brand;
  final String model;
  final String categoryId;
  final String categoryName;
  final double dailyPrice;
  final VehicleStatus status;
  final String? branchId;
  final String? branchName;
  final int? year;
  final String fuelType;
  final String transmission;
  final int currentKm;
  final double depositAmount;
  final List<String> features;

  String get displayName => '$brand $model';
  String get priceLabel => '₺${dailyPrice.toStringAsFixed(0)}/gün';

  String get fuelTypeLabel => switch (fuelType) {
        'petrol' => 'Benzin',
        'diesel' => 'Dizel',
        'electric' => 'Elektrik',
        'hybrid' => 'Hibrit',
        _ => fuelType,
      };

  String get transmissionLabel =>
      transmission == 'automatic' ? 'Otomatik' : 'Manuel';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    List<String> parsedFeatures = [];
    if (rawFeatures is List) {
      parsedFeatures = rawFeatures.map((e) => e.toString()).toList();
    }

    return Vehicle(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      plateNumber: json['plate_number'] as String,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String? ?? '',
      dailyPrice: _toDouble(json['daily_base_price']),
      status: VehicleStatus.fromDb(json['status'] as String? ?? 'available'),
      branchId: json['branch_id'] as String?,
      branchName: json['branch_name'] as String?,
      year: json['year'] as int?,
      fuelType: json['fuel_type'] as String? ?? 'petrol',
      transmission: json['transmission'] as String? ?? 'automatic',
      currentKm: json['current_km'] as int? ?? 0,
      depositAmount: _toDouble(json['deposit_amount']),
      features: parsedFeatures,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [id];
}
